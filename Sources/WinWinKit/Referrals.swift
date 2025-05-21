//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  Referrals.swift
//
//  Created by Oleh Stasula on 03/12/2024.
//

import AnyCodable
import Foundation
import Logging

///
/// The error type for ``Referrals``.
///
public enum ReferralsError: Error {
    case appUserIdNotSet
}

///
/// The entry point for WinWinKit SDK.
/// Normally it should be instantiated as soon as your app has a unique user id for your user.
/// This can be when a user logs in if you have accounts or on launch if you can generate a random user identifier.
///
public final class Referrals {
    ///
    /// Returns the already configured instance of ``Referrals``.
    /// - Warning: this method will crash with `fatalError` if ``Referrals`` has not been initialized through
    /// ``Referrals/configure(apiKey:)`` or one of its overloads.
    /// If there's a chance that may have not happened yet, you can use ``isConfigured`` to check if it's safe to call.
    ///
    /// ### Example
    ///
    /// ```swift
    /// Referrals.shared
    /// ```
    ///
    public static var shared: Referrals {
        guard
            let instance
        else {
            fatalError("Referrals has not been configured yet. To get started call `Referrals.configure(apiKey:).`")
        }
        return instance
    }

    ///
    /// Initialize an instance of the Referrals SDK.
    ///
    /// - Parameter apiKey: The API key you wish to use to configure ``Referrals``.
    ///
    /// - Parameter keyValueCache: The key-value cache where ``Referrals`` can store data.
    /// The default value is `UserDefaults.standard`.
    /// You may set any other instance of `UserDefaults`.
    ///
    /// - Parameter logLevel: The log level.
    /// The default value is `info`.
    /// You may want to set it to `debug` for debugging purposes.
    ///
    /// - Parameter baseEndpointURL: The url to the API endpoint of `WinWinKit`.
    /// The default value is `https://api.winwinkit.com`.
    /// You don't need to use this parameter, and it is here for performing internal testing.
    ///
    /// - Returns: An instance of ``Referrals`` object.
    ///
    /// ### Example
    ///
    /// ```swift
    /// Referrals.configure(apiKey: "<YOUR_API_KEY>")
    /// ```
    ///
    /// ```swift
    /// Referrals.configure(apiKey: "<YOUR_API_KEY>",
    ///                     keyValueCache: UserDefaults(suiteName: "<YOUR_APP_GROUP>"),
    ///                     logLevel: .debug)
    /// ```
    ///
    @discardableResult
    public static func configure(apiKey: String,
                                 keyValueCache: KeyValueCacheType = UserDefaults.standard,
                                 logLevel: Logger.Level = .info) -> Referrals
    {
        if let instance {
            Logger.error("Referrals has already been configured. Calling `configure` again has no effect.")
            return instance
        }

        Logger.logLevel = logLevel

        let instance = Referrals(
            apiKey: apiKey,
            keyValueCache: keyValueCache
        )
        self.instance = instance
        return instance
    }

    ///
    /// Returns `true` if Referrals has already been initialized through ``Referrals/configure(apiKey:)``.
    ///
    public static var isConfigured: Bool {
        instance != nil
    }

    public var delegate: ReferralsDelegate? {
        get { self._delegate }
        set {
            guard newValue !== self._delegate else {
                Logger.warning("Referrals delegate has already been set.")
                return
            }

            if newValue == nil {
                Logger.info("Referrals delegate is being set to nil, you probably don't want to do this.")
            }

            self._delegate = newValue

            if newValue != nil {
                Logger.debug("Referrals delegate is set.")
            }
        }
    }

    ///
    /// Returns the latest available `User` object.
    ///
    public var user: User? {
        self.userService?.cachedUser
    }

    @available(iOS 17.0, macOS 14.0, *)
    public var userObservableObject: UserObservableObject {
        if let retained = self.retainedUserObservableObject {
            return retained
        }
        let created = UserObservableObject()
        created.set(user: self.userService?.cachedUser)
        created.set(isRefreshing: self.userService?.isRefreshing ?? false)
        self._userObservableObject = created
        return created
    }

    @available(iOS 17.0, macOS 14.0, *)
    public var claimReferralCodeObservableObject: ClaimReferralCodeObservableObject {
        if let retained = self.retainedClaimReferralCodeObservableObject {
            return retained
        }
        let created = ClaimReferralCodeObservableObject()
        created.set(isClaimingCode: self.userService?.isClaimingCode ?? false)
        created.onClaimCode = { [weak self] code in
            self?.claim(referralCode: code, completion: { _ in })
        }
        self._claimReferralCodeObservableObject = created
        return created
    }

    public func claim(referralCode code: String) async throws -> (User, UserRewardsGranted) {
        try await withCheckedThrowingContinuation { continuation in
            self.claim(referralCode: code, completion: { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }

    public func claim(referralCode code: String, completion: @escaping (Result<(User, UserRewardsGranted), Error>) -> Void) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before claiming code.")
            completion(.failure(ReferralsError.appUserIdNotSet))
            return
        }

        if #available(iOS 17.0, macOS 14.0, *) {
            self.retainedClaimReferralCodeObservableObject?.set(isClaimingCode: true)
        }

        userService.claim(referralCode: code) { [weak self] result in
            if #available(iOS 17.0, macOS 14.0, *) {
                self?.retainedClaimReferralCodeObservableObject?.set(isClaimingCode: false)

                switch result {
                case let .success(data):
                    self?.retainedClaimReferralCodeObservableObject?.set(didClaimCodeSuccesfully: true)
                    self?.retainedClaimReferralCodeObservableObject?.set(rewardsGranted: data.rewardsGranted)
                case .failure:
                    self?.retainedClaimReferralCodeObservableObject?.set(didClaimCodeSuccesfully: false)
                }
            }

            completion(result.map { ($0.user, $0.rewardsGranted) })
        }
    }

    public func fetchOfferCode(offerCodeId: String) async throws -> (AppStoreOfferCode, AppStoreSubscription) {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchOfferCode(offerCodeId: offerCodeId, completion: { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            })
        }
    }

    public func fetchOfferCode(offerCodeId: String, completion: @escaping (Result<(AppStoreOfferCode, AppStoreSubscription), Error>) -> Void) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before fetching offer code.")
            return
        }

        userService.fetchOfferCode(offerCodeId: offerCodeId) { result in
            completion(result.map { ($0.offerCode, $0.subscription) })
        }
    }

    ///
    /// Sets your app's user unique identifier.
    /// - Parameter appUserId: Unique identifier of your app's user.
    /// Referral program and rewards will be attached to the `appUserId`.
    /// Use UUID or similar random identifier types.
    /// **Avoid setting person identifying information**, like email or name.
    ///
    public func set(appUserId: String) {
        self.startNetworkReachability()

        let userService = UserService(
            appUserId: appUserId,
            apiKey: self.apiKey,
            offerCodeProvider: self.offerCodeProvider,
            userCache: self.userCache,
            userClaimActionsProvider: self.userClaimActionsProvider,
            userProvider: self.userProvider
        )
        self.userService = userService

        userService.delegate = self
        if self.shouldAutoUpdateLastSeenAt {
            userService.set(lastSeenAt: .now)
        }
        userService.refresh()
    }

    ///
    /// Sets user's premium status.
    /// - Parameter isPremium: Is user premium.
    ///
    public func set(isPremium: Bool) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        if userService.cachedUser?.isPremium == isPremium {
            return
        }
        userService.set(isPremium: isPremium)
        userService.refresh()
    }

    ///
    /// Sets user's first seen at date.
    /// - Parameter firstSeenAt: Date when user has been seen at first. Must not be date in the future.
    ///
    public func set(firstSeenAt: Date) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        guard
            firstSeenAt <= .now
        else {
            Logger.warning("First seen at date must not be in the future.")
            return
        }
        if firstSeenAt.isPracticallyTheSame(as: userService.cachedUser?.firstSeenAt) {
            return
        }
        userService.set(firstSeenAt: firstSeenAt)
        userService.refresh()
    }

    ///
    /// Sets user's last seen at date.
    /// - Parameter lastSeenAt: Date when user has been seen at first. Must not be date in the future.
    ///
    public func set(lastSeenAt: Date) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        guard
            lastSeenAt <= .now
        else {
            Logger.warning("Last seen at date must not be in the future.")
            return
        }
        if lastSeenAt.isPracticallyTheSame(as: userService.cachedUser?.lastSeenAt) {
            return
        }
        userService.set(lastSeenAt: lastSeenAt)
        userService.refresh()
    }

    ///
    /// Sets user's metadata.
    /// - Parameter metadata: Metadata object.
    ///
    public func set(metadata: AnyCodable) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        if userService.cachedUser?.metadata == metadata {
            return
        }
        userService.set(metadata: metadata)
        userService.refresh()
    }

    ///
    /// Resets internal state attached to previously set `appUserId`.
    ///
    public func reset() {
        self.userService = nil
        self.userCache.reset()
        self.delegate?.referrals(self, receivedUpdated: nil)
    }

    ///
    /// A flag controlling whether `lastSeenAt` should be auto-updated or not.
    /// Set to `false` **before** calling `set(appUserId:)` if you do not want user's `lastSeenAt` property be auto-updated at initialization.
    /// Additionally, you can always update it by calling `Referrals.shared.set(lastSeenAt: <NEW_DATE>)`.
    /// The default value is `true`.
    ///
    public var shouldAutoUpdateLastSeenAt: Bool {
        get {
            self._shouldAutoUpdateLastSeenAt
        }
        set {
            self._shouldAutoUpdateLastSeenAt = newValue
        }
    }

    // MARK: - Private

    @Atomic
    private static var instance: Referrals? = nil

    private let apiKey: String
    private let networkReachability: NetworkReachabilityType
    private let offerCodeProvider: OfferCodeProviderType
    private let userCache: UserCacheType
    private let userClaimActionsProvider: UserClaimActionsProviderType
    private let userProvider: UserProviderType

    private weak var _delegate: ReferralsDelegate?

    @Atomic
    private var _shouldAutoUpdateLastSeenAt: Bool = true

    private weak var _userObservableObject: AnyObject?

    @available(iOS 17.0, macOS 14.0, *)
    private var retainedUserObservableObject: UserObservableObject? {
        self._userObservableObject as? UserObservableObject
    }

    private weak var _claimReferralCodeObservableObject: AnyObject?

    @available(iOS 17.0, macOS 14.0, *)
    private var retainedClaimReferralCodeObservableObject: ClaimReferralCodeObservableObject? {
        self._claimReferralCodeObservableObject as? ClaimReferralCodeObservableObject
    }

    @Atomic
    private var userService: UserService?

    private convenience init(apiKey: String,
                             keyValueCache: KeyValueCacheType)
    {
        let networkReachability = NetworkReachability()
        let offerCodeProvider = OfferCodeProvider()
        let userCache = UserCache(keyValueCache: keyValueCache)
        let userClaimActionsProvider = UserClaimActionsProvider()
        let userProvider = UserProvider()

        self.init(
            apiKey: apiKey,
            networkReachability: networkReachability,
            offerCodeProvider: offerCodeProvider,
            userCache: userCache,
            userClaimActionsProvider: userClaimActionsProvider,
            userProvider: userProvider
        )
    }

    private init(apiKey: String,
                 networkReachability: NetworkReachabilityType,
                 offerCodeProvider: OfferCodeProviderType,
                 userCache: UserCacheType,
                 userClaimActionsProvider: UserClaimActionsProviderType,
                 userProvider: UserProviderType)
    {
        self.apiKey = apiKey
        self.networkReachability = networkReachability
        self.offerCodeProvider = offerCodeProvider
        self.userCache = userCache
        self.userClaimActionsProvider = userClaimActionsProvider
        self.userProvider = userProvider
    }

    private func startNetworkReachability() {
        guard
            self.networkReachability.delegate == nil
        else { return }
        self.networkReachability.delegate = self
        self.networkReachability.start()
    }
}

extension Referrals: NetworkReachabilityDelegate {
    func networkHasBecomeReachable(_: any NetworkReachabilityType) {
        self.userService?.refresh()
    }
}

extension Referrals: UserServiceDelegate {
    func userServiceCanPerformNextRefresh(_: UserService) -> Bool {
        self.networkReachability.isReachable
    }

    func userService(_: UserService, receivedUpdated user: User) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedUserObservableObject?.set(user: user)
        }
        self.delegate?.referrals(self, receivedUpdated: user)
    }

    func userService(_: UserService, receivedError error: any Error) {
        self.delegate?.referrals(self, receivedError: error)
    }

    func userService(_: UserService, isRefreshingChanged isRefreshing: Bool) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedUserObservableObject?.set(isRefreshing: isRefreshing)
        }
        self.delegate?.referrals(self, isRefreshingChanged: isRefreshing)
    }
}
