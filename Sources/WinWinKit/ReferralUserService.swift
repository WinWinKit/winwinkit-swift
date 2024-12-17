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
        
        self.networkReachability.hasBecomeReachable = { [weak self] in
            self?.refreshReferralUser(force: true)
        }
        
        self.networkReachability.start()
        
        self.refreshReferralUser()
    }
    
    public func set(isPremium: Bool) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(isPremium: isPremium) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: isPremium,
                               userSince: nil,
                               lastSeenAt: nil)
        )
    }
    
    public func set(userSince: Date) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(userSince: userSince) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               userSince: userSince,
                               lastSeenAt: nil)
        )
    }
    
    public func set(lastSeenAt: Date) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(lastSeenAt: lastSeenAt) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               userSince: nil,
                               lastSeenAt: lastSeenAt)
        )
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
    
    internal weak var internalDelegate: ReferralUserServiceDelegate? = nil {
        didSet {
            guard
                let internalDelegate
            else { return }
            if let cachedReferralUser {
                internalDelegate.referralUserService(self, receivedUpdated: cachedReferralUser)
            }
            if self.refreshingTask != nil {
                internalDelegate.referralUserService(self, isRefreshingChanged: true)
            }
        }
    }
    
    internal func startIfNeeded() {
        if !self.hasStartedOnce {
            self.start()
        }
    }
    
    // MARK: - Private
    
    private let appUserId: String
    private let projectKey: String
    private let networkReachability: NetworkReachabilityType
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private weak var _delegate: ReferralUserServiceDelegate? = nil
    
    private var hasRefreshedOnce: Bool = false
    private var hasStartedOnce: Bool = false
    
    private var shouldPullOnNextRefresh: Bool = false
    
    private var refreshingTask: Task<Void, Never>?
    
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
    
    private func cacheReferralUser(_ referralUser: ReferralUser) {
        self.referralUserCache.referralUser = referralUser
        self.internalDelegate?.referralUserService(self, receivedUpdated: referralUser)
        self.delegate?.referralUserService(self, receivedUpdated: referralUser)
    }
    
    private func cacheUpdateReferralUser(_ referralUser: UpdateReferralUser) {
        self.referralUserCache.updateReferralUser = referralUser
        self.refreshReferralUser()
    }
    
    private func resetUpdateReferralUser(with referralUser: UpdateReferralUser?) {
        if self.referralUserCache.updateReferralUser == referralUser {
            self.referralUserCache.updateReferralUser = nil
        }
    }
    
    private func refreshReferralUser(force: Bool = false) {
        
        if !self.networkReachability.isReachable {
            self.shouldPullOnNextRefresh = true
            return
        }
        
        if self.refreshingTask != nil {
            self.shouldPullOnNextRefresh = self.shouldPullOnNextRefresh || force
            return
        }
        
        self.refreshingTask = Task { @MainActor in
            
            self.internalDelegate?.referralUserService(self, isRefreshingChanged: true)
            self.delegate?.referralUserService(self, isRefreshingChanged: true)
            
            var completedSuccessfully = false
            
            do {
                if !self.hasRefreshedOnce || self.shouldPullOnNextRefresh || force,
                   let referralUser = try await self.referralUserProvider.fetch(appUserId: self.appUserId, projectKey: self.projectKey) {
                    self.cacheReferralUser(referralUser)
                    if let updateReferralUser = self.pendingUpdateReferralUser {
                        let updatedReferralUser = try await self.referralUserProvider.update(referralUser: updateReferralUser,
                                                                                             projectKey: self.projectKey)
                        self.resetUpdateReferralUser(with: updateReferralUser)
                        self.cacheReferralUser(updatedReferralUser)
                    }
                }
                else if self.cachedReferralUser != nil {
                    if let updateReferralUser = self.pendingUpdateReferralUser {
                        let updatedReferralUser = try await self.referralUserProvider.update(referralUser: updateReferralUser,
                                                                                             projectKey: self.projectKey)
                        self.resetUpdateReferralUser(with: updateReferralUser)
                        self.cacheReferralUser(updatedReferralUser)
                    }
                }
                else {
                    let updateReferralUser = self.pendingUpdateReferralUser
                    let insertReferralUser = updateReferralUser?.asInsertReferralUser ?? InsertReferralUser(appUserId: self.appUserId, isPremium: nil, userSince: nil, lastSeenAt: nil)
                    let referralUser = try await self.referralUserProvider.create(referralUser: insertReferralUser,
                                                                                  projectKey: self.projectKey)
                    self.resetUpdateReferralUser(with: updateReferralUser)
                    self.cacheReferralUser(referralUser)
                }
                
                self.hasRefreshedOnce = true
                
                completedSuccessfully = true
            }
            catch {
                Logger.error("Failed to refresh referral user: \(String(describing: error))")
            }
            
            self.refreshingTask = nil
            self.internalDelegate?.referralUserService(self, isRefreshingChanged: false)
            self.delegate?.referralUserService(self, isRefreshingChanged: false)
            
            if completedSuccessfully && self.shouldPullOnNextRefresh || self.pendingUpdateReferralUser != nil {
                self.shouldPullOnNextRefresh = false
                self.refreshReferralUser()
            }
        }
    }
}
