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
    let referralClaimCodeProvider: ReferralClaimCodeProviderType
    
    init(appUserId: String,
         projectKey: String,
         referralUserCache: ReferralUserCacheType,
         referralUserProvider: ReferralUserProviderType,
         referralClaimCodeProvider: ReferralClaimCodeProviderType) {
        
        self.appUserId = appUserId
        self.projectKey = projectKey
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
        self.referralClaimCodeProvider = referralClaimCodeProvider
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
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(isPremium: isPremium) ??
            ReferralUserUpdate(appUserId: self.appUserId,
                               isPremium: isPremium,
                               firstSeenAt: nil,
                               lastSeenAt: nil,
                               metadata: nil)
        )
    }
    
    func set(firstSeenAt: Date) {
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(firstSeenAt: firstSeenAt) ??
            ReferralUserUpdate(appUserId: self.appUserId,
                               isPremium: nil,
                               firstSeenAt: firstSeenAt,
                               lastSeenAt: nil,
                               metadata: nil)
        )
    }
    
    func set(lastSeenAt: Date) {
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(lastSeenAt: lastSeenAt) ??
            ReferralUserUpdate(appUserId: self.appUserId,
                               isPremium: nil,
                               firstSeenAt: nil,
                               lastSeenAt: lastSeenAt,
                               metadata: nil)
        )
    }
    
    func set(metadata: Metadata) {
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(metadata: metadata) ??
            ReferralUserUpdate(appUserId: self.appUserId,
                               isPremium: nil,
                               firstSeenAt: nil,
                               lastSeenAt: nil,
                               metadata: metadata)
        )
    }
    
    var isRefreshing: Bool {
        self.refreshTask != nil
    }
    
    func refresh() {
        
        if self.shouldSuspendIndefinitely {
            return
        }
        
        if let delegate,
           !delegate.referralUserServiceCanPerformNextRefresh(self) {
            Logger.debug("ReferralUserService: Refresh not allowed")
            return
        }
        
        if self.refreshTask != nil {
            Logger.debug("ReferralUserService: Refresh already in progress")
            return
        }
        
        self.refreshTask = Task { @MainActor in
            
            Logger.debug("ReferralUserService: Refresh will start")
            
            self.delegate?.referralUserService(self, isRefreshingChanged: true)
            
            var completedSuccessfully = false
            
            do {
                
                if self.cachedReferralUser == nil {
                    // Create (or update) referral user if don't have it in cache
                    let referralUserUpdate = self.pendingReferralUserUpdate ?? ReferralUserUpdate(appUserId: self.appUserId, isPremium: nil, firstSeenAt: nil, lastSeenAt: nil, metadata: nil)
                    let referralUser = try await self.referralUserProvider.createOrUpdate(referralUser: referralUserUpdate,
                                                                                          projectKey: self.projectKey)
                    Logger.debug("ReferralUserService: Refresh did create referral user")
                    self.resetReferralUserUpdate(with: referralUserUpdate)
                    self.cacheReferralUser(referralUser)
                }
                else if let referralUserUpdate = self.pendingReferralUserUpdate {
                    // Update referral user if has anything to update
                    let updatedReferralUser = try await self.referralUserProvider.createOrUpdate(referralUser: referralUserUpdate,
                                                                                                 projectKey: self.projectKey)
                    Logger.debug("ReferralUserService: Refresh did update referral user")
                    self.resetReferralUserUpdate(with: referralUserUpdate)
                    self.cacheReferralUser(updatedReferralUser)
                }
                else if let referralUser = try await self.referralUserProvider.fetch(appUserId: self.appUserId, projectKey: self.projectKey) {
                    // Fetch referral user to get latest value.
                    Logger.debug("ReferralUserService: Refresh did fetch referral user")
                    self.cacheReferralUser(referralUser)
                }
                else {
                    // Create referral user if received nil on fetch request.
                    let referralUserUpdate = self.pendingReferralUserUpdate ?? ReferralUserUpdate(appUserId: self.appUserId, isPremium: nil, firstSeenAt: nil, lastSeenAt: nil, metadata: nil)
                    let referralUser = try await self.referralUserProvider.createOrUpdate(referralUser: referralUserUpdate,
                                                                                          projectKey: self.projectKey)
                    Logger.debug("ReferralUserService: Refresh did re-create referral user")
                    self.resetReferralUserUpdate(with: referralUserUpdate)
                    self.cacheReferralUser(referralUser)
                }
                
                completedSuccessfully = true
                
                Logger.debug("ReferralUserService: Refresh did finish")
            }
            catch {
                Logger.debug("ReferralUserService: Refresh did fail")
                Logger.error("Failed to refresh referral user: \(String(describing: error))")
                
                self.handleTaskError(error)
            }
            
            self.refreshTask = nil
            self.delegate?.referralUserService(self, isRefreshingChanged: false)
            
            if completedSuccessfully && self.pendingReferralUserUpdate != nil {
                Logger.debug("ReferralUserService: Refresh will start again")
                self.refresh()
            }
        }
    }
    
    var isClaimingCode: Bool {
        self.claimCodeTask != nil
    }
    
    func claim(code: String, completion: @escaping (Result<ReferralClaimCodeResult, Error>) -> Void) {
        
        if self.shouldSuspendIndefinitely {
            return
        }
        
        if self.claimCodeTask != nil {
            Logger.debug("ReferralUserService: Claim code skipped because of already claiming code")
            return
        }
        
        self.claimCodeTask = Task { @MainActor in
            do {
                let referralClaimCodeData = try await self.referralClaimCodeProvider.claim(code: code,
                                                                                           appUserId: self.appUserId,
                                                                                           projectKey: self.projectKey)
                
                Logger.debug("ReferralUserService: Claim code did finish")
                
                self.cacheReferralUser(referralClaimCodeData.referralUser)
                
                self.claimCodeTask = nil
                
                completion(.success(referralClaimCodeData))
            }
            catch {
                Logger.debug("ReferralUserService: Claim code did fail")
                Logger.error("Failed to claim code: \(String(describing: error))")
                
                self.handleTaskError(error)
                
                self.claimCodeTask = nil
                
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private var shouldSuspendIndefinitely: Bool = false
    
    private var claimCodeTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    private var pendingReferralUserUpdate: ReferralUserUpdate? {
        get {
            if let referralUser = self.referralUserCache.referralUserUpdate,
               referralUser.appUserId == self.appUserId {
                return referralUser
            }
            return nil
        }
        set {
            self.referralUserCache.referralUserUpdate = newValue
        }
    }
    
    private func cacheReferralUser(_ referralUser: ReferralUser) {
        self.referralUserCache.referralUser = referralUser
        self.delegate?.referralUserService(self, receivedUpdated: referralUser)
    }
    
    private func cacheReferralUserUpdate(_ referralUser: ReferralUserUpdate) {
        self.referralUserCache.referralUserUpdate = referralUser
    }
    
    private func resetReferralUserUpdate(with referralUser: ReferralUserUpdate?) {
        if self.referralUserCache.referralUserUpdate == referralUser {
            self.referralUserCache.referralUserUpdate = nil
        }
    }
    
    private func handleTaskError(_ error: Error) {
        if let dispatcherError = error as? RemoteRequestDispatcherError,
           dispatcherError == .unauthorized {
            self.referralUserCache.reset()
            self.shouldSuspendIndefinitely = true
            
            Logger.error("Authorization with the provided project key has failed! Please obtain a new project key and use it when initializing the Referrals object.")
        }
        
        self.delegate?.referralUserService(self, receivedError: error)
    }
}
