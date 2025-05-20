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
                                 baseEndpointURL: URL = URL(string: "https://api.winwinkit.com")!) -> Referrals {
        
        if let instance {
            Logger.error("Referrals has already been configured. Calling `configure` again has no effect.")
            return instance
        }
        
        Logger.logLevel = logLevel
        
        let instance = Referrals(apiKey: apiKey,
                                 keyValueCache: keyValueCache,
                                 baseEndpointURL: baseEndpointURL)
        self.instance = instance
        return instance
    }
    
    ///
    /// Returns `true` if Referrals has already been initialized through ``Referrals/configure(apiKey:)``.
    ///
    public static var isConfigured: Bool {
        Self.instance != nil
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
        self.referralUserService?.cachedReferralUser
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    public var referralUserObservableObject: ReferralUserObservableObject {
        if let retained = self.retainedReferralUserObservableObject {
            return retained
        }
        let created = ReferralUserObservableObject()
        created.set(user: self.referralUserService?.cachedReferralUser)
        created.set(isRefreshing: self.referralUserService?.isRefreshing ?? false)
        self._referralUserObservableObject = created
        return created
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    public var referralClaimCodeObservableObject: ReferralClaimCodeObservableObject {
        if let retained = self.retainedReferralClaimCodeObservableObject {
            return retained
        }
        let created = ReferralClaimCodeObservableObject()
        created.set(isClaimingCode: self.referralUserService?.isClaimingCode ?? false)
        created.onClaimCode = { [weak self] code in
            self?.claim(code: code, completion: { _ in })
        }
        self._referralClaimCodeObservableObject = created
        return created
    }
    
    public func claim(code: String, completion: @escaping (Result<(User, UserRewardsGranted), Error>) -> Void) {
        guard
            let referralUserService
        else {
            Logger.warning("User identifier `appUserId` must be set before claiming code.")
            return
        }
        
        if #available(iOS 17.0, macOS 14.0, *) {
            self.retainedReferralClaimCodeObservableObject?.set(isClaimingCode: true)
        }
        
        referralUserService.claim(code: code) { [weak self] result in
            if #available(iOS 17.0, macOS 14.0, *) {
                self?.retainedReferralClaimCodeObservableObject?.set(isClaimingCode: false)
                
                switch result {
                case .success(let data):
                    self?.retainedReferralClaimCodeObservableObject?.set(didClaimCodeSuccesfully: true)
                    self?.retainedReferralClaimCodeObservableObject?.set(grantedRewards: data.grantedRewards)
                case .failure:
                    self?.retainedReferralClaimCodeObservableObject?.set(didClaimCodeSuccesfully: false)
                }
            }
            
            completion(result.map { ($0.user, $0.grantedRewards) })
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
        
        let referralUserService = ReferralUserService(appUserId: appUserId,
                                                      apiKey: self.apiKey,
                                                      userCache: self.userCache,
                                                      userProvider: self.userProvider,
                                                      userClaimActionsProvider: self.userClaimActionsProvider)
        self.referralUserService = referralUserService
        
        referralUserService.delegate = self
        if self.shouldAutoUpdateLastSeenAt {
            referralUserService.set(lastSeenAt: .now)
        }
        referralUserService.refresh()
    }
    
    ///
    /// Sets user's premium status.
    /// - Parameter isPremium: Is user premium.
    ///
    public func set(isPremium: Bool) {
        guard
            let referralUserService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        if referralUserService.cachedReferralUser?.isPremium == isPremium {
            return
        }
        referralUserService.set(isPremium: isPremium)
        referralUserService.refresh()
    }
    
    ///
    /// Sets user's first seen at date.
    /// - Parameter firstSeenAt: Date when user has been seen at first. Must not be date in the future.
    ///
    public func set(firstSeenAt: Date) {
        guard
            let referralUserService
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
        if firstSeenAt.isPracticallyTheSame(as: referralUserService.cachedReferralUser?.firstSeenAt) {
            return
        }
        referralUserService.set(firstSeenAt: firstSeenAt)
        referralUserService.refresh()
    }
    
    ///
    /// Sets user's last seen at date.
    /// - Parameter lastSeenAt: Date when user has been seen at first. Must not be date in the future.
    ///
    public func set(lastSeenAt: Date) {
        guard
            let referralUserService
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
        if lastSeenAt.isPracticallyTheSame(as: referralUserService.cachedReferralUser?.lastSeenAt) {
            return
        }
        referralUserService.set(lastSeenAt: lastSeenAt)
        referralUserService.refresh()
        
    }
    
    ///
    /// Sets user's metadata.
    /// - Parameter metadata: Metadata object.
    ///
    public func set(metadata: AnyCodable) {
        guard
            let referralUserService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
            return
        }
        if referralUserService.cachedReferralUser?.metadata == metadata {
            return
        }
        referralUserService.set(metadata: metadata)
        referralUserService.refresh()
    }
    
    ///
    /// Resets internal state attached to previously set `appUserId`.
    ///
    public func reset() {
        self.referralUserService = nil
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
    private let userCache: UserCacheType
    private let userProvider: UserProviderType
    private let userClaimActionsProvider: UserClaimActionsProviderType
    
    private weak var _delegate: ReferralsDelegate? = nil
    
    @Atomic
    private var _shouldAutoUpdateLastSeenAt: Bool = true
    
    private weak var _referralUserObservableObject: AnyObject?
    
    @available(iOS 17.0, macOS 14.0, *)
    private var retainedReferralUserObservableObject: ReferralUserObservableObject? {
        self._referralUserObservableObject as? ReferralUserObservableObject
    }
    
    private weak var _referralClaimCodeObservableObject: AnyObject?
    
    @available(iOS 17.0, macOS 14.0, *)
    private var retainedReferralClaimCodeObservableObject: ReferralClaimCodeObservableObject? {
        self._referralClaimCodeObservableObject as? ReferralClaimCodeObservableObject
    }
    
    @Atomic
    private var referralUserService: ReferralUserService?
    
    private convenience init(apiKey: String,
                             keyValueCache: KeyValueCacheType,
                             baseEndpointURL: URL) {
        
        let networkReachability = NetworkReachability()
        let userCache = UserCache(keyValueCache: keyValueCache)
        let userProvider = UserProvider()
        let userClaimActionsProvider = UserClaimActionsProvider()
        
        self.init(apiKey: apiKey,
                  networkReachability: networkReachability,
                  userCache: userCache,
                  userProvider: userProvider,
                  userClaimActionsProvider: userClaimActionsProvider)
    }
    
    private init(apiKey: String,
                 networkReachability: NetworkReachabilityType,
                 userCache: UserCacheType,
                 userProvider: UserProviderType,
                 userClaimActionsProvider: UserClaimActionsProviderType) {
        
        self.apiKey = apiKey
        self.networkReachability = networkReachability
        self.userCache = userCache
        self.userProvider = userProvider
        self.userClaimActionsProvider = userClaimActionsProvider
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
    
    internal func networkHasBecomeReachable(_ networkReachability: any NetworkReachabilityType) {
        self.referralUserService?.refresh()
    }
}

extension Referrals: ReferralUserServiceDelegate {
    
    internal func referralUserServiceCanPerformNextRefresh(_ service: ReferralUserService) -> Bool {
        self.networkReachability.isReachable
    }
    
    internal func referralUserService(_ service: ReferralUserService, receivedUpdated user: User) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedReferralUserObservableObject?.set(user: user)
        }
        self.delegate?.referrals(self, receivedUpdated: user)
    }
    
    internal func referralUserService(_ service: ReferralUserService, receivedError error: any Error) {
        self.delegate?.referrals(self, receivedError: error)
    }
    
    internal func referralUserService(_ service: ReferralUserService, isRefreshingChanged isRefreshing: Bool) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedReferralUserObservableObject?.set(isRefreshing: isRefreshing)
        }
        self.delegate?.referrals(self, isRefreshingChanged: isRefreshing)
    }
}
