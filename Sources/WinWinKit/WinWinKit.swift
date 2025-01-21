//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  WinWinKit.swift
//
//  Created by Oleh Stasula on 03/12/2024.
//

import Foundation
import Logging

///
/// The entry point for WinWinKit SDK.
/// Normally it should be instantiated as soon as your app has a unique user id for your user.
/// This can be when a user logs in if you have accounts or on launch if you can generate a random user identifier.
///
public final class WinWinKit {
    
    ///
    /// Returns the already configured instance of ``WinWinKit``.
    /// - Warning: this method will crash with `fatalError` if ``WinWinKit`` has not been initialized through
    /// ``WinWinKit/configure(projectKey:)`` or one of its overloads.
    /// If there's a chance that may have not happened yet, you can use ``isConfigured`` to check if it's safe to call.
    ///
    /// ### Example
    ///
    /// ```swift
    /// WinWinKit.shared
    /// ```
    ///
    public static var shared: WinWinKit {
        guard
            let instance
        else {
            fatalError("WinWinKit has not been configured yet. To get started call `WinWinKit.configure(projectKey:).`")
        }
        return instance
    }
    
    ///
    /// Initialize an instance of the WinWinKit SDK.
    ///
    /// - Parameter projectKey: The project key you wish to use to configure ``WinWinKit``.
    ///
    /// - Parameter keyValueCache: The key-value cache where ``WinWinKit`` can store data.
    /// The default value is `UserDefaults.standard`.
    /// You may set any other instance of `UserDefaults`.
    ///
    /// - Parameter logLevel: The log level.
    /// The default value is `info`.
    /// You may want to set it to `debug` for debugging purposes.
    ///
    /// - Returns: An instance of ``WinWinKit`` object.
    ///
    /// ### Example
    ///
    /// ```swift
    /// WinWinKit.configure(projectKey: "<YOUR_PROJECT_KEY>")
    /// ```
    ///
    /// ```swift
    /// WinWinKit.configure(projectKey: "<YOUR_PROJECT_KEY>",
    ///                     keyValueCache: UserDefaults(suiteName: "<YOUR_APP_GROUP>"),
    ///                     logLevel: .debug)
    /// ```
    ///
    @discardableResult
    public static func configure(projectKey: String,
                                 keyValueCache: KeyValueCacheType = UserDefaults.standard,
                                 logLevel: Logger.Level = .info) -> WinWinKit {
        
        if let instance {
            Logger.error("WinWinKit has already been configured. Calling `configure` again has no effect.")
            return instance
        }
        
        Logger.logLevel = logLevel
        
        let instance = WinWinKit(projectKey: projectKey,
                                 keyValueCache: keyValueCache)
        self.instance = instance
        return instance
    }
    
    ///
    /// Returns `true` if WinWinKit has already been initialized through ``WinWinKit/configure(projectKey:)``.
    ///
    public static var isConfigured: Bool {
        Self.instance != nil
    }
    
    public var delegate: WinWinKitDelegate? {
        get { self._delegate }
        set {
            guard newValue !== self._delegate else {
                Logger.warning("WinWinKit delegate has already been set.")
                return
            }
            
            if newValue == nil {
                Logger.info("WinWinKit delegate is being set to nil, you probably don't want to do this.")
            }
            
            self._delegate = newValue
            
            if newValue != nil {
                Logger.debug("WinWinKit delegate is set.")
            }
        }
    }
    
    ///
    /// Returns the latest available `ReferralUser` object.
    ///
    public var referralUser: ReferralUser? {
        self.referralUserService?.cachedReferralUser
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    public var referralUserObservableObject: ReferralUserObservableObject {
        if let retained = self.retainedReferralUserObservableObject {
            return retained
        }
        let created = ReferralUserObservableObject()
        created.set(referralUser: self.referralUserService?.cachedReferralUser)
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
        created.onClaimCode = { [weak self] code in
            self?.claim(code: code, completion: { _ in })
        }
        self._referralClaimCodeObservableObject = created
        return created
    }
    
    public func claim(code: String, completion: @escaping (Result<ReferralUser, Error>) -> Void) {
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
                case .success:
                    self?.retainedReferralClaimCodeObservableObject?.set(didClaimCodeSuccesfully: true)
                case .failure:
                    self?.retainedReferralClaimCodeObservableObject?.set(didClaimCodeSuccesfully: false)
                }
            }
            
            completion(result)
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
                                                      projectKey: self.projectKey,
                                                      referralUserCache: self.referralUserCache,
                                                      referralUserProvider: self.referralUserProvider)
        self.referralUserService = referralUserService
        
        referralUserService.delegate = self
        if self.shouldAutoUpdateLastSeenAt {
            referralUserService.set(lastSeenAt: Date())
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
            firstSeenAt <= Date()
        else {
            Logger.warning("First seen at date must not be in the future.")
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
            lastSeenAt <= Date()
        else {
            Logger.warning("Last seen at date must not be in the future.")
            return
        }
        referralUserService.set(lastSeenAt: lastSeenAt)
        referralUserService.refresh()
    }
    
    ///
    /// Sets user's metadata.
    /// - Parameter metadata: Metadata object.
    ///
    public func set(metadata: Metadata) {
        guard
            let referralUserService
        else {
            Logger.warning("User identifier `appUserId` must be set before updating any other user properties.")
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
        self.referralUserCache.reset()
        self.delegate?.winWinKit(self, receivedUpdated: nil)
    }
    
    ///
    /// A flag controlling whether `lastSeenAt` should be auto-updated or not.
    /// Set to `false` **before** calling `set(appUserId:)` if you do not want user's `lastSeenAt` property be auto-updated at initialization.
    /// Additionally, you can always update it by calling `WinWinKit.shared.set(lastSeenAt: <NEW_DATE>)`.
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
    private static var instance: WinWinKit? = nil
    
    private let projectKey: String
    private let networkReachability: NetworkReachabilityType
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private weak var _delegate: WinWinKitDelegate? = nil
    
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
    
    private convenience init(projectKey: String,
                             keyValueCache: KeyValueCacheType) {
        
        let networkReachability = NetworkReachability()
        let referralUserCache = ReferralUserCache(keyValueCache: keyValueCache)
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let remoteDataFetcher = RemoteDataFetcher(session: .shared)
        let remoteRequestDispatcher = RemoteRequestDispatcher(remoteDataFetcher: remoteDataFetcher)
        let referralUserProvider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                              remoteRequestDispatcher: remoteRequestDispatcher)
        
        self.init(projectKey: projectKey,
                  networkReachability: networkReachability,
                  referralUserCache: referralUserCache,
                  referralUserProvider: referralUserProvider)
    }
    
    private init(projectKey: String,
                 networkReachability: NetworkReachabilityType,
                 referralUserCache: ReferralUserCacheType,
                 referralUserProvider: ReferralUserProviderType) {
        
        self.projectKey = projectKey
        self.networkReachability = networkReachability
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
    }
    
    private func startNetworkReachability() {
        guard
            self.networkReachability.delegate == nil
        else { return }
        self.networkReachability.delegate = self
        self.networkReachability.start()
    }
}

extension WinWinKit: NetworkReachabilityDelegate {
    
    internal func networkHasBecomeReachable(_ networkReachability: any NetworkReachabilityType) {
        self.referralUserService?.refresh(shouldPull: true)
    }
}

extension WinWinKit: ReferralUserServiceDelegate {
    
    internal func referralUserServiceCanPerformNextRefresh(_ service: ReferralUserService) -> Bool {
        self.networkReachability.isReachable
    }
    
    internal func referralUserService(_ service: ReferralUserService, receivedUpdated referralUser: ReferralUser) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedReferralUserObservableObject?.set(referralUser: referralUser)
        }
        self.delegate?.winWinKit(self, receivedUpdated: referralUser)
    }
    
    internal func referralUserService(_ service: ReferralUserService, isRefreshingChanged isRefreshing: Bool) {
        if #available(iOS 17, macOS 14, *) {
            self.retainedReferralUserObservableObject?.set(isRefreshing: isRefreshing)
        }
        self.delegate?.winWinKit(self, isRefreshingChanged: isRefreshing)
    }
}
