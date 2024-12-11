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
    /// - Parameter referralUserCache: Destination for caching referral user data.
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
                            referralUserCache: ReferralUserCacheType = UserDefaults.standard) {
        
        let networkReachability = NetworkReachability()
        
        let baseEndpointURL = URL(string: "https://app.winwinkit.com/api/")!
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
                // TODO: log same delegate is set multiple times
                return
            }
            
            if newValue == nil {
                // TODO: log delegate is set to nil
            }
            
            self._delegate = newValue
            
            if newValue != nil {
                // TODO: log delegate is set
            }
        }
    }
    
    public var cachedReferralUser: ReferralUser? {
        do {
            let referralUser = try self.referralUserCache[CacheKeys.referralUser].map { try ReferralUser(jsonData: $0) }
            if referralUser?.appUserId == self.appUserId {
                return referralUser
            }
        }
        catch {
            // TODO: log warning
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
    
    private let appUserId: String
    private let projectKey: String
    private let networkReachability: NetworkReachabilityType
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private weak var _delegate: ReferralUserServiceDelegate? = nil
    
    private var hasStartedOnce: Bool = false
    
    private var pendingUpdateReferralUser: UpdateReferralUser? {
        get {
            do {
                let referralUser = try self.referralUserCache[CacheKeys.updateReferralUser].map { try UpdateReferralUser(jsonData: $0) }
                if referralUser?.appUserId == self.appUserId {
                    return referralUser
                }
            }
            catch {
                // TODO: log warning
            }
            return nil
        }
        set {
            do {
                self.referralUserCache[CacheKeys.updateReferralUser] = try newValue?.jsonData()
            }
            catch {
                // TODO: log warning
            }
        }
    }
    
    private func handleNetworkHasBecomeReachable() {
        // TODO:
    }
    
    private enum CacheKeys {
        static let referralUser = "com.winwinkit.cache.referralUser"
        static let updateReferralUser = "com.winwinkit.cache.updateReferralUser"
    }
}
