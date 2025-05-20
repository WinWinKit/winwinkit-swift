//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserServiceTests.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Testing
@testable import WinWinKit

@Suite struct ReferralUserServiceTests {

    @Test func initilization() {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        #expect(service.cachedReferralUser == nil)
        #expect(service.delegate == nil)
    }
    
    @Test func cachedReferralUser() {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        #expect(service.cachedReferralUser == nil)
        referralUserCache.referralUser = MockReferralUser.Full.object
        #expect(service.cachedReferralUser == MockReferralUser.Full.object)
        referralUserCache.referralUser = MockReferralUser.Empty.object
        #expect(service.cachedReferralUser == nil)
    }
    
    @Test func delegate() {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        #expect(service.delegate == nil)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        #expect(service.delegate === delegate)
        var weakDelegate: ReferralUserServiceDelegate?
        weakDelegate = MockReferralUserServiceDelegate()
        service.delegate = weakDelegate
        #expect(service.delegate === weakDelegate)
        weakDelegate = nil
        #expect(service.delegate == nil)
    }
    
    @Test func refreshFailsWithNoData() async throws {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 0)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func refreshFailsWithNoDataAndHasNoFollowingRefresh() async throws {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 0)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            service.refresh()
            
            service.set(isPremium: true)
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func refreshFailsWithUnauthorized() async throws {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        userProvider.errorToThrowOnFetch = RemoteRequestDispatcherError.unauthorized
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 0)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func refreshFailsAndResetsCacheWithUnauthorized() async throws {
        let referralUserCache = MockReferralUserCache()
        referralUserCache.referralUser = MockReferralUser.Full.object
        let userProvider = MockReferralUserProvider()
        userProvider.errorToThrowOnFetch = RemoteRequestDispatcherError.unauthorized
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 1)
                    #expect(userProvider.createMethodCallsCounter == 0)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func createReferralUser() async throws {
        let referralUserCache = MockReferralUserCache()
        let userProvider = MockReferralUserProvider()
        userProvider.referralUserToReturnOnCreate = MockReferralUser.Full.object
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("creates referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 0)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == MockReferralUser.Full.object)
                }
            }
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func updateReferralUser() async throws {
        let referralUserCache = MockReferralUserCache()
        referralUserCache.referralUser = MockReferralUser.Full.object
        let userProvider = MockReferralUserProvider()
        let updateMetadata: Metadata = ["value": 123]
        let updatedReferralUser = MockReferralUser.Full.object.set(metadata: updateMetadata)
        userProvider.referralUserToReturnOnCreate = updatedReferralUser
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("updates referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 0)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == updatedReferralUser)
                }
            }
            service.set(metadata: updateMetadata)
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func createAndUpdateReferralUser() {
    }
    
    @Test func claimReferralCode() {
    }
    
    @Test func referralUserDeletedOnRemoteCreatesNewReferralUser() async throws {
        let referralUserCache = MockReferralUserCache()
        referralUserCache.referralUser = MockReferralUser.Full.object
        let userProvider = MockReferralUserProvider()
        let expectedReferralUser = MockReferralUser.Full.object.set(metadata: nil)
        userProvider.referralUserToReturnOnCreate = expectedReferralUser
        let userClaimActionsProvider = MockReferralClaimCodeProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          apiKey: MockConstants.apiKey,
                                          referralUserCache: referralUserCache,
                                          userProvider: userProvider,
                                          userClaimActionsProvider: userClaimActionsProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("creates new referral user") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(userProvider.fetchMethodCallsCounter == 1)
                    #expect(userProvider.createMethodCallsCounter == 1)
                    #expect(userProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == expectedReferralUser)
                }
            }
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
}
