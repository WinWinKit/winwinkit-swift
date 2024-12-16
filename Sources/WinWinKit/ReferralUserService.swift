//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserService.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

import Foundation

public final class ReferralUserService {
    
    ///
    /// Initialize an instance of the ``ReferralUserService`.
    ///
    /// - Parameter appUserId: Unique identifier of your app's user.
    /// Referral program and rewards will be attached to the `appUserId`.
    /// Use UUID or similar random identifier types.
    /// **Avoid setting person identifying information**, like email or name.
    ///
    /// - Parameter projectKey: The project key to configure ``ReferralUserService`` with.
    /// Obtain ``projectKey`` in the settings of your project in [WinWinKit dashboard](https://app.winwinkit.com).
    ///
    /// - Parameter keyValueCache: Destination for caching referral user data.
    /// The default value is ``UserDefaults.standard``.
    ///
    /// - Returns: An instance of ``ReferralUserService``.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let service = ReferralUserService(appUserId: "<YOUR_APP_USER_ID>",
    ///                                   projectKey: "<YOUR_PROJECT_KEY>")
    /// ```
    ///
    public convenience init(appUserId: String,
                            projectKey: String,
                            keyValueCache: KeyValueCacheType = UserDefaults.standard) {
        
        let networkReachability = NetworkReachability()
        
        let referralUserCache = ReferralUserCache(keyValueCache: keyValueCache)
        
        let baseEndpointURL = URL(string: "https://api.winwinkit.com/")!
        let requestDispatcher = RemoteReferralUserRequestDispatcher(session: .shared)
        let referralUserProvider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                              requestDispatcher: requestDispatcher)
        
        self.init(appUserId: appUserId,
                  projectKey: projectKey,
                  networkReachability: networkReachability,
                  referralUserCache: referralUserCache,
                  referralUserProvider: referralUserProvider)
    }
    
    public var delegate: ReferralUserServiceDelegate? {
        get { self._delegate }
        set {
            guard newValue !== self._delegate else {
                Logger.warning("ReferralUserService delegate has already been set.")
                return
            }
            
            if newValue == nil {
                Logger.info("ReferralUserService delegate is being set to nil, you probably don't want to do this.")
            }
            
            self._delegate = newValue
            
            if newValue != nil {
                Logger.debug("ReferralUserService delegate is set.")
            }
        }
    }
    
    public var cachedReferralUser: ReferralUser? {
        if let referralUser = self.referralUserCache.referralUser,
           referralUser.appUserId == self.appUserId {
            return referralUser
        }
        return nil
    }
    
    public func start() {
        guard
            !self.hasStartedOnce
        else { return } // TODO: log warning
        
        self.hasStartedOnce = true
        
        self.networkReachability.start()
        
        self.networkReachability.hasBecomeReachable = { [weak self] in
            self?.handleNetworkHasBecomeReachable()
        }
        
        if self.cachedReferralUser != nil {
            // pull from remote
            // update cache
            // call delegate
        }
        else {
            // pull from remote
            // if not found - register
            // update cache
            // call delegate
        }
    }
    
    public func set(isPremium: Bool) {
        self.pendingUpdateReferralUser = (
            self.pendingUpdateReferralUser?.set(isPremium: isPremium) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: isPremium,
                               userSince: nil,
                               lastSeenAt: nil)
        )
        // TODO: push changes
    }
    
    public func set(userSince: Date) {
        self.pendingUpdateReferralUser = (
            self.pendingUpdateReferralUser?.set(userSince: userSince) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               userSince: userSince,
                               lastSeenAt: nil)
        )
        // TODO: push changes
    }
    
    public func set(lastSeenAt: Date) {
        self.pendingUpdateReferralUser = (
            self.pendingUpdateReferralUser?.set(lastSeenAt: lastSeenAt) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               userSince: nil,
                               lastSeenAt: lastSeenAt)
        )
        // TODO: push changes
    }
    
    public func set(metadata: Any?) {
        // TODO:
    }
    
    // MARK: - Internal
    
    internal init(appUserId: String,
                  projectKey: String,
                  networkReachability: NetworkReachabilityType,
                  referralUserCache: ReferralUserCacheType,
                  referralUserProvider: ReferralUserProviderType) {
        
        self.appUserId = appUserId
        self.projectKey = projectKey
        self.networkReachability = networkReachability
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
    }
    
    // MARK: - Private
    
    private let appUserId: String
    private let projectKey: String
    private let networkReachability: NetworkReachabilityType
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private weak var _delegate: ReferralUserServiceDelegate? = nil
    
    private var hasStartedOnce: Bool = false
    
    private var pendingUpdateReferralUser: UpdateReferralUser? {
        get {
            if let referralUser = self.referralUserCache.updateReferralUser,
               referralUser.appUserId == self.appUserId {
                return referralUser
            }
            return nil
        }
        set {
            self.referralUserCache.updateReferralUser = newValue
        }
    }
    
    private func handleNetworkHasBecomeReachable() {
        // TODO:
    }
}
