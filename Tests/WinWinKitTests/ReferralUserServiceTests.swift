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
    
    @Test func createReferralUser() {
        
    }
    
    @Test func createAndUpdateReferralUser() {
    }
    
    @Test func claimReferralCode() {
    }
}
