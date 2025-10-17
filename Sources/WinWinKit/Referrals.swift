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
public enum ReferralsError: Error, Equatable {
    /// The app user id must be set before using any other methods.
    case appUserIdNotSet
    /// Service is suspended indefinitely.
    ///
    /// Normally this happens after receiving unauthorized error from WinWinKit API.
    /// Obtain a new API key and configure ``Referrals`` with a valid one.
    case suspendedIndefinitely
    /// Request to WinWinKit API has failed with provided errors.
    case requestFailure(_ errorObjects: [ErrorObject])

    public var errorObjects: [ErrorObject]? {
        switch self {
        case let .requestFailure(errorObjects):
            return errorObjects
        default:
            return nil
        }
    }
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
                                 logLevel: Logger.Level = .info,
                                 baseEndpointURL: URL? = nil) -> Referrals
    {
        if let instance {
            Logger.error("Referrals has already been configured. Calling `configure` again has no effect.")
            return instance
        }

        Logger.logLevel = logLevel

        if let baseEndpointURL {
            WinWinKitAPI.basePath = baseEndpointURL.absoluteString
        }

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

    ///
    /// Creates a new `ReferralsObservableObject` object, or returns a retained instance if it already exists.
    ///
    /// The returned instance is weakly referenced from the SDK.
    /// It is your responsibility to retain it throughout the lifecycle of you View or App.
    /// If the instance is released from memory, calling this property will create a new one.
    ///
    @available(iOS 17.0, macOS 14.0, *)
    public var observableObject: ReferralsObservableObject {
        if let retained = self.retainedObservableObject {
            return retained
        }
        let created = ReferralsObservableObject()
        let user = self.userService?.cachedUser
        created.user = user
        created.userState = (self.userService?.isRefreshing == true ? .loading : (user != nil ? .available : .none))
        created.onClaimCode = { [weak self] code in
            self?.claimCode(code: code) { _ in }
        }
        created.onFetchOfferCode = { [weak self] offerCodeId in
            self?.fetchOfferCode(offerCodeId: offerCodeId) { _ in }
        }
        self._observableObject = created
        return created
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
            providers: self.providers,
            userCache: self.userCache
        )
        self.userService = userService

        userService.delegate = self

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
    /// Sets user's trial status.
    /// - Parameter isTrial: Is user trial.
    ///
    public func set(isTrial: Bool) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        if userService.cachedUser?.isTrial == isTrial {
            return
        }
        userService.set(isTrial: isTrial)
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
        if firstSeenAt.isEqualToSeconds(with: userService.cachedUser?.firstSeenAt) {
            return
        }
        userService.set(firstSeenAt: firstSeenAt)
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
    /// Claim a code. Code can be affiliate, promo or referral code.
    ///
    /// - Parameter code: The code to claim. Can be affiliate, promo or referral code.
    ///
    /// - Returns: A tuple containing the updated user and the rewards granted.
    ///
    /// - Throws: An error if the code is not found or the user is not eligible to claim it.
    ///
    public func claimCode(code: String) async throws -> (User, UserRewardsGranted) {
        try await withCheckedThrowingContinuation { continuation in
            self.claimCode(code: code) { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    ///
    /// Claim a code. Code can be affiliate, promo or referral code.
    ///
    /// - Parameter code: The code to claim. Can be affiliate, promo or referral code.
    /// - Parameter completion: A closure to be called when the claim is complete.
    ///
    public func claimCode(code: String, completion: @escaping (Result<(User, UserRewardsGranted), Error>) -> Void) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before claiming code.")
            completion(.failure(ReferralsError.appUserIdNotSet))
            return
        }

        if #available(iOS 17.0, macOS 14.0, *) {
            self.retainedObservableObject?.claimCodeState = .loading
        }

        userService.claimCode(code: code) { [weak self] result in
            if #available(iOS 17.0, macOS 14.0, *) {
                switch result {
                case let .success(data):
                    self?.retainedObservableObject?.claimCodeState = .success(data.rewardsGranted)
                case let .failure(error):
                    self?.retainedObservableObject?.claimCodeState = .failure(error)
                }
            }

            completion(result.map { ($0.user, $0.rewardsGranted) })
        }
    }

    ///
    /// Withdraw credits.
    ///
    /// - Parameter key: The key of the credits to withdraw.
    /// - Parameter amount: The amount of credits to withdraw.
    ///
    /// - Returns: A tuple containing the updated user and the result of the withdrawal.
    ///
    /// - Throws: An error if the user is not found or the withdrawal fails.
    ///
    public func withdrawCredits(key: String, amount: Int) async throws -> (User, UserWithdrawCreditsResult) {
        try await withCheckedThrowingContinuation { continuation in
            self.withdrawCredits(key: key, amount: amount) { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    ///
    /// Withdraw credits.
    ///
    /// - Parameter key: The key of the credits to withdraw.
    /// - Parameter amount: The amount of credits to withdraw.
    /// - Parameter completion: A closure to be called when the withdrawal is complete.
    ///
    public func withdrawCredits(key: String, amount: Int, completion: @escaping (Result<(User, UserWithdrawCreditsResult), Error>) -> Void) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before withdrawing credits.")
            completion(.failure(ReferralsError.appUserIdNotSet))
            return
        }

        userService.withdrawCredits(key: key, amount: amount) { result in
            completion(result.map { ($0.user, $0.withdrawResult) })
        }
    }

    ///
    /// Fetch an offer code.
    ///
    /// - Parameter offerCodeId: The id of the offer code to fetch.
    ///
    /// - Returns: A tuple containing the offer code and the subscription.
    ///
    /// - Throws: An error if the offer code is not found or the user is not eligible to fetch it.
    ///
    public func fetchOfferCode(offerCodeId: String) async throws -> (AppStoreOfferCode, AppStoreSubscription) {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchOfferCode(offerCodeId: offerCodeId) { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    ///
    /// Fetch an offer code.
    ///
    /// - Parameter offerCodeId: The id of the offer code to fetch.
    /// - Parameter completion: A closure to be called when the offer code is fetched.
    ///
    public func fetchOfferCode(offerCodeId: String, completion: @escaping (Result<(AppStoreOfferCode, AppStoreSubscription), Error>) -> Void) {
        guard
            let userService
        else {
            Logger.warning("User identifier `appUserId` must be set before fetching offer code.")
            completion(.failure(ReferralsError.appUserIdNotSet))
            return
        }

        if #available(iOS 17.0, macOS 14.0, *) {
            self.retainedObservableObject?.offerCodesState[offerCodeId] = .loading
        }

        userService.fetchOfferCode(offerCodeId: offerCodeId) { result in
            if #available(iOS 17.0, macOS 14.0, *) {
                switch result {
                case let .success(data):
                    self.retainedObservableObject?.offerCodesState[offerCodeId] = .success(data.offerCode, data.subscription)
                case let .failure(error):
                    self.retainedObservableObject?.offerCodesState[offerCodeId] = .failure(error)
                }
            }
            completion(result.map { ($0.offerCode, $0.subscription) })
        }
    }

    ///
    /// Resets internal state attached to previously set `appUserId`.
    ///
    public func reset() {
        self.userService = nil
        self.userCache.reset()
        self.delegate?.referrals(self, receivedUpdated: nil)
    }

    // MARK: - Internal

    init(apiKey: String,
         networkReachability: NetworkReachabilityType,
         providers: UserService.Providers,
         userCache: UserCacheType)
    {
        self.apiKey = apiKey
        self.networkReachability = networkReachability
        self.providers = providers
        self.userCache = userCache
    }

    // MARK: - Private

    @Atomic
    private static var instance: Referrals? = nil

    private let apiKey: String
    private let networkReachability: NetworkReachabilityType
    private let providers: UserService.Providers
    private let userCache: UserCacheType

    private weak var _delegate: ReferralsDelegate?

    private weak var _observableObject: AnyObject?

    @available(iOS 17.0, macOS 14.0, *)
    private var retainedObservableObject: ReferralsObservableObject? {
        self._observableObject as? ReferralsObservableObject
    }

    @Atomic
    private var userService: UserService?

    private convenience init(apiKey: String,
                             keyValueCache: KeyValueCacheType)
    {
        let networkReachability = NetworkReachability()
        let userCache = UserCache(keyValueCache: keyValueCache)
        let providers = UserService.Providers(
            claimActions: ClaimActionsProvider(),
            offerCodes: OfferCodesProvider(),
            rewardActions: RewardActionsProvider(),
            users: UsersProvider()
        )

        self.init(
            apiKey: apiKey,
            networkReachability: networkReachability,
            providers: providers,
            userCache: userCache
        )
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
            self.retainedObservableObject?.user = user
            self.retainedObservableObject?.userState = .available
        }
        self.delegate?.referrals(self, receivedUpdated: user)
    }

    func userService(_: UserService, receivedError error: any Error) {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.retainedObservableObject?.userState = .failure(error)
        }
        self.delegate?.referrals(self, receivedError: error)
    }

    func userService(_: UserService, changedIsRefreshing isRefreshing: Bool) {
        if #available(iOS 17.0, macOS 14.0, *) {
            if isRefreshing { // If false, then userState is set in other delegate methods
                self.retainedObservableObject?.userState = .loading
            }
        }
    }
}
