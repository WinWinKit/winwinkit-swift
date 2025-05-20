//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralUserServiceDelegate.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import WinWinKit
@testable import WinWinKit

final class MockReferralUserServiceDelegate: ReferralUserServiceDelegate {
    
    var canPerformNextRefresh: Bool = true
    var referralUser: ReferralUser? = nil
    var isRefreshing: Bool? = nil
    
    var canPerformNextRequestMethodCallsCounter: Int = 0
    var receivedUpdatedReferralUserMethodCallsCounter: Int = 0
    var isRefreshingChangedMethodCallsCounter: Int = 0
    
    var isRefreshingChangedCallback: ((Bool) -> Void)?
    
    func referralUserServiceCanPerformNextRefresh(_ service: UserService) -> Bool {
        self.canPerformNextRequestMethodCallsCounter += 1
        return self.canPerformNextRefresh
    }
    
    func referralUserService(_ service: UserService, receivedUpdated referralUser: ReferralUser) {
        self.referralUser = referralUser
        self.receivedUpdatedReferralUserMethodCallsCounter += 1
    }
    
    func referralUserService(_ service: UserService, receivedError error: any Error) {
    }
    
    func referralUserService(_ service: UserService, isRefreshingChanged isRefreshing: Bool) {
        self.isRefreshing = isRefreshing
        self.isRefreshingChangedMethodCallsCounter += 1
        self.isRefreshingChangedCallback?(isRefreshing)
    }
}
