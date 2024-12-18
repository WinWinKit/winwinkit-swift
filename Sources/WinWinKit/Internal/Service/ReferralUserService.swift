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

final class ReferralUserService {
    
    let appUserId: String
    let projectKey: String
    let referralUserCache: ReferralUserCacheType
    let referralUserProvider: ReferralUserProviderType
    
    init(appUserId: String,
         projectKey: String,
         referralUserCache: ReferralUserCacheType,
         referralUserProvider: ReferralUserProviderType) {
        
        self.appUserId = appUserId
        self.projectKey = projectKey
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
    }
    
    weak var delegate: ReferralUserServiceDelegate?
    
    var cachedReferralUser: ReferralUser? {
        if let referralUser = self.referralUserCache.referralUser,
           referralUser.appUserId == self.appUserId {
            return referralUser
        }
        return nil
    }
    
    func set(isPremium: Bool) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(isPremium: isPremium) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: isPremium,
                               firstSeenAt: nil,
                               lastSeenAt: nil)
        )
    }
    
    func set(firstSeenAt: Date) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(firstSeenAt: firstSeenAt) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               firstSeenAt: firstSeenAt,
                               lastSeenAt: nil)
        )
    }
    
    func set(lastSeenAt: Date) {
        self.cacheUpdateReferralUser(
            self.pendingUpdateReferralUser?.set(lastSeenAt: lastSeenAt) ??
            UpdateReferralUser(appUserId: self.appUserId,
                               isPremium: nil,
                               firstSeenAt: nil,
                               lastSeenAt: lastSeenAt)
        )
    }
    
    func set(metadata: Any?) {
        // TODO:
    }
    
    func refresh(shouldPull: Bool = false) {
        
        if let delegate,
           !delegate.referralUserServiceCanPerformNextRefresh(self) {
            self.shouldPullOnNextRefresh = self.shouldPullOnNextRefresh || shouldPull
            return
        }
        
        if self.refreshingTask != nil {
            self.shouldPullOnNextRefresh = self.shouldPullOnNextRefresh || shouldPull
            return
        }
        
        self.refreshingTask = Task { @MainActor in
            
            self.delegate?.referralUserService(self, isRefreshingChanged: true)
            
            var completedSuccessfully = false
            
            do {
                if !self.hasRefreshedOnce || self.shouldPullOnNextRefresh || shouldPull,
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
                    let insertReferralUser = updateReferralUser?.asInsertReferralUser ?? InsertReferralUser(appUserId: self.appUserId, isPremium: nil, firstSeenAt: nil, lastSeenAt: nil)
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
            self.delegate?.referralUserService(self, isRefreshingChanged: false)
            
            if completedSuccessfully && self.shouldPullOnNextRefresh || self.pendingUpdateReferralUser != nil {
                self.shouldPullOnNextRefresh = false
                self.refresh()
            }
        }
    }
    
    // MARK: - Private
    
    private var hasRefreshedOnce: Bool = false
    
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
        self.delegate?.referralUserService(self, receivedUpdated: referralUser)
    }
    
    private func cacheUpdateReferralUser(_ referralUser: UpdateReferralUser) {
        self.referralUserCache.updateReferralUser = referralUser
    }
    
    private func resetUpdateReferralUser(with referralUser: UpdateReferralUser?) {
        if self.referralUserCache.updateReferralUser == referralUser {
            self.referralUserCache.updateReferralUser = nil
        }
    }
}
