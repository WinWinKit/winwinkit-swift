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
    
    var referralUser: ReferralUser? = nil
    var receivedUpdatedMethodCallCount: Int = 0
    
    func receivedUpdated(referralUser: ReferralUser) {
        self.referralUser = referralUser
        self.receivedUpdatedMethodCallCount += 1
    }
}
