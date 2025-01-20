//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserCodableTests.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct ReferralUserCodableTests {
    
    @Test func encoding() throws {
        let referralUser = try ReferralUser(jsonData: MockReferralUser.Full.data)
        let expectedReferralUser = MockReferralUser.Full.object
        #expect(referralUser == expectedReferralUser)
    }
}
