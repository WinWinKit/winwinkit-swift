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

import AnyCodable
import Foundation

final class ReferralUserService {
    
    let appUserId: String
    let apiKey: String
    let referralUserCache: ReferralUserCacheType
    let userProvider: UserProviderType
    let userClaimActionsProvider: UserClaimActionsProviderType
    
    init(appUserId: String,
         apiKey: String,
         referralUserCache: ReferralUserCacheType,
         userProvider: UserProviderType,
         userClaimActionsProvider: UserClaimActionsProviderType) {
        
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.referralUserCache = referralUserCache
        self.userProvider = userProvider
        self.userClaimActionsProvider = userClaimActionsProvider
    }
    
    weak var delegate: ReferralUserServiceDelegate?
    
    var cachedReferralUser: User? {
        if let referralUser = self.referralUserCache.user,
           referralUser.appUserId == self.appUserId {
            return referralUser
        }
        return nil
    }
    
    func set(isPremium: Bool) {
        Logger.debug("ReferralUserService: Set isPremium value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(isPremium: isPremium) ??
            UserUpdate(appUserId: self.appUserId,
                       isPremium: isPremium,
                       firstSeenAt: nil,
                       lastSeenAt: nil,
                       metadata: nil)
        )
    }
    
    func set(firstSeenAt: Date) {
        Logger.debug("ReferralUserService: Set firstSeenAt value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(firstSeenAt: firstSeenAt) ??
            UserUpdate(appUserId: self.appUserId,
                       isPremium: nil,
                       firstSeenAt: firstSeenAt,
                       lastSeenAt: nil,
                       metadata: nil)
        )
    }
    
    func set(lastSeenAt: Date) {
        Logger.debug("ReferralUserService: Set lastSeenAt value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(lastSeenAt: lastSeenAt) ??
            UserUpdate(appUserId: self.appUserId,
                       isPremium: nil,
                       firstSeenAt: nil,
                       lastSeenAt: lastSeenAt,
                       metadata: nil)
        )
    }
    
    func set(metadata: AnyCodable) {
        Logger.debug("ReferralUserService: Set metadata value")
        self.cacheReferralUserUpdate(
            self.pendingReferralUserUpdate?.set(metadata: metadata) ??
            UserUpdate(appUserId: self.appUserId,
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
            Logger.debug("ReferralUserService: Refresh suspended indefinitely")
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
                    let referralUserUpdate = self.pendingReferralUserUpdate ?? UserUpdate(appUserId: self.appUserId, isPremium: nil, firstSeenAt: nil, lastSeenAt: nil, metadata: nil)
                    let request = UserCreateRequest(
                        appUserId: referralUserUpdate.appUserId,
                        isPremium: referralUserUpdate.isPremium,
                        firstSeenAt: referralUserUpdate.firstSeenAt,
                        lastSeenAt: referralUserUpdate.lastSeenAt,
                        metadata: referralUserUpdate.metadata
                    )
                    let referralUser = try await self.userProvider.createOrUpdate(request: request,
                                                                                          apiKey: self.apiKey)
                    Logger.debug("ReferralUserService: Refresh did create referral user")
                    self.resetReferralUserUpdate(with: referralUserUpdate)
                    self.cacheReferralUser(referralUser)
                }
                else if let referralUserUpdate = self.pendingReferralUserUpdate {
                    // Update referral user if has anything to update
                    let request = UserCreateRequest(
                        appUserId: referralUserUpdate.appUserId,
                        isPremium: referralUserUpdate.isPremium,
                        firstSeenAt: referralUserUpdate.firstSeenAt,
                        lastSeenAt: referralUserUpdate.lastSeenAt,
                        metadata: referralUserUpdate.metadata
                    )
                    let updatedReferralUser = try await self.userProvider.createOrUpdate(request: request,
                                                                                                 apiKey: self.apiKey)
                    Logger.debug("ReferralUserService: Refresh did update referral user")
                    self.resetReferralUserUpdate(with: referralUserUpdate)
                    self.cacheReferralUser(updatedReferralUser)
                }
//                else if let referralUser = try await self.userProvider.fetch(appUserId: self.appUserId, apiKey: self.apiKey) {
//                    // Fetch referral user to get latest value.
//                    Logger.debug("ReferralUserService: Refresh did fetch referral user")
//                    self.cacheReferralUser(referralUser)
//                }
                else {
                    // Create referral user if received nil on fetch request.
                    let referralUserUpdate = self.pendingReferralUserUpdate ?? UserUpdate(appUserId: self.appUserId, isPremium: nil, firstSeenAt: nil, lastSeenAt: nil, metadata: nil)
                    let request = UserCreateRequest(
                        appUserId: referralUserUpdate.appUserId,
                        isPremium: referralUserUpdate.isPremium,
                        firstSeenAt: referralUserUpdate.firstSeenAt,
                        lastSeenAt: referralUserUpdate.lastSeenAt,
                        metadata: referralUserUpdate.metadata
                    )
                    let referralUser = try await self.userProvider.createOrUpdate(request: request,
                                                                                          apiKey: self.apiKey)
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
    
    func claim(code: String, completion: @escaping (Result<UserClaimReferralCodeResponse, Error>) -> Void) {
        
        if self.shouldSuspendIndefinitely {
            Logger.debug("ReferralUserService: Claim code suspended indefinitely")
            return
        }
        
        if self.claimCodeTask != nil {
            Logger.debug("ReferralUserService: Claim code skipped because of already claiming code")
            return
        }
        
        self.claimCodeTask = Task { @MainActor in
            do {
                let request = UserClaimReferralCodeRequest(code: code)
                let referralClaimCodeData = try await self.userClaimActionsProvider.claim(request: request,
                                                                                           appUserId: self.appUserId,
                                                                                           apiKey: self.apiKey)
                
                Logger.debug("ReferralUserService: Claim code did finish")
                
                self.cacheReferralUser(referralClaimCodeData.user)
                
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
    
    private var pendingReferralUserUpdate: UserUpdate? {
        get {
            if let referralUser = self.referralUserCache.userUpdate,
               referralUser.appUserId == self.appUserId {
                return referralUser
            }
            return nil
        }
        set {
            self.referralUserCache.userUpdate = newValue
        }
    }
    
    private func cacheReferralUser(_ user: User) {
        self.referralUserCache.user = user
        self.delegate?.referralUserService(self, receivedUpdated: user)
    }
    
    private func cacheReferralUserUpdate(_ userUpdate: UserUpdate) {
        self.referralUserCache.userUpdate = userUpdate
    }
    
    private func resetReferralUserUpdate(with user: UserUpdate?) {
        if self.referralUserCache.userUpdate == user {
            self.referralUserCache.userUpdate = nil
        }
    }
    
    private func handleTaskError(_ error: Error) {
        if let dispatcherError = error as? ErrorResponse {
            switch dispatcherError {
            case .error(let status, _, _, _):
                if status == 401 {
                    self.referralUserCache.reset()
                    self.shouldSuspendIndefinitely = true
                    
                    Logger.error("Authorization with the provided API key has failed! Please obtain a new API key and use it when initializing the Referrals object.")
                }
            }
        }
        
        self.delegate?.referralUserService(self, receivedError: error)
    }
}
