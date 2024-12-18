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
    /// - Returns: An instance of ``WinWinKit`` object.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let winWinKit = WinWinKit.configure(projectKey: "<YOUR_PROJECT_KEY>")
    /// ```
    ///
    public static func configure(projectKey: String) -> WinWinKit {
        self.configure(projectKey: projectKey,
                       keyValueCache: UserDefaults.standard)
    }
    
    public static func configure(projectKey: String, keyValueCache: KeyValueCacheType) -> WinWinKit {
        
        if let instance {
            Logger.error("WinWinKit has already been configured. Calling `configure(projectKey:)` again has no effect.")
            return instance
        }
        
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
        referralUserService.delegate = self
        self.referralUserService = referralUserService
    }
    
    ///
    /// Resets internal state attached to previously set `appUserId`.
    ///
    public func reset() {
        self.referralUserService = nil
        self.referralUserCache.reset()
        self.delegate?.winWinKit(self, receivedUpdated: nil)
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
    
    func networkHasBecomeReachable(_ networkReachability: any NetworkReachabilityType) {
        // TODO: trigger next refresh for current service
    }
}

extension WinWinKit: ReferralUserServiceDelegate {
    
    func referralUserServiceCanPerformNextRefresh(_ service: ReferralUserService) -> Bool {
        self.networkReachability.isReachable
    }
    
    func referralUserService(_ service: ReferralUserService, receivedUpdated referralUser: ReferralUser) {
        self.delegate?.winWinKit(self, receivedUpdated: referralUser)
    }
    
    func referralUserService(_ service: ReferralUserService, isRefreshingChanged isRefreshing: Bool) {
        self.delegate?.winWinKit(self, isRefreshingChanged: isRefreshing)
    }
}
