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
        let referralUserProvider = MockReferralUserProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        #expect(service.cachedReferralUser == nil)
        #expect(service.delegate == nil)
    }
    
    @Test func cachedReferralUser() {
        let referralUserCache = MockReferralUserCache()
        let referralUserProvider = MockReferralUserProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        #expect(service.cachedReferralUser == nil)
        referralUserCache.referralUser = MockReferralUser.Full.object
        #expect(service.cachedReferralUser == MockReferralUser.Full.object)
        referralUserCache.referralUser = MockReferralUser.Empty.object
        #expect(service.cachedReferralUser == nil)
    }
    
    @Test func delegate() {
        let referralUserCache = MockReferralUserCache()
        let referralUserProvider = MockReferralUserProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
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
        let referralUserProvider = MockReferralUserProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(referralUserProvider.fetchMethodCallsCounter == 1)
                    #expect(referralUserProvider.createMethodCallsCounter == 1)
                    #expect(referralUserProvider.updateMethodCallsCounter == 0)
                    #expect(referralUserProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func refreshFailsWithNoDataAndHasNoFollowingRefresh() async throws {
        let referralUserCache = MockReferralUserCache()
        let referralUserProvider = MockReferralUserProvider()
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("fails to create") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(referralUserProvider.fetchMethodCallsCounter == 1)
                    #expect(referralUserProvider.createMethodCallsCounter == 1)
                    #expect(referralUserProvider.updateMethodCallsCounter == 0)
                    #expect(referralUserProvider.claimMethodCallsCounter == 0)
                    
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
        let referralUserProvider = MockReferralUserProvider()
        referralUserProvider.errorToThrowOnFetch = RemoteRequestDispatcherError.unauthorized
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(referralUserProvider.fetchMethodCallsCounter == 1)
                    #expect(referralUserProvider.createMethodCallsCounter == 0)
                    #expect(referralUserProvider.updateMethodCallsCounter == 0)
                    #expect(referralUserProvider.claimMethodCallsCounter == 0)
                    
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
        let referralUserProvider = MockReferralUserProvider()
        referralUserProvider.errorToThrowOnFetch = RemoteRequestDispatcherError.unauthorized
        let service = ReferralUserService(appUserId: MockReferralUser.Full.object.appUserId,
                                          projectKey: MockConstants.projectKey,
                                          referralUserCache: referralUserCache,
                                          referralUserProvider: referralUserProvider)
        let delegate = MockReferralUserServiceDelegate()
        service.delegate = delegate
        
        try await confirmation("stops indefinetely") { c in
            delegate.isRefreshingChangedCallback = { isRefreshing in
                if !isRefreshing {
                    c.confirm()
                    
                    #expect(referralUserProvider.fetchMethodCallsCounter == 1)
                    #expect(referralUserProvider.createMethodCallsCounter == 0)
                    #expect(referralUserProvider.updateMethodCallsCounter == 0)
                    #expect(referralUserProvider.claimMethodCallsCounter == 0)
                    
                    #expect(service.cachedReferralUser == nil)
                }
            }
            service.refresh()
            
            try await Task.sleep(for: .milliseconds(50))
        }
    }
    
    @Test func createAndUpdateReferralUser() {
    }
    
    @Test func claimReferralCode() {
    }
}
