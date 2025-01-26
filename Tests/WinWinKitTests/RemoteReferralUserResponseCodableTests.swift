//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserResponseCodableTests.swift
//
//  Created by Oleh Stasula on 26/01/2025.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct RemoteReferralUserResponseCodableTests {
    
    @Test func encoding() throws {
        let referralUserResponse = try RemoteReferralUserResponse(jsonData: MockReferralUserResponse.Full.data)
        let expectedReferralUserResponse = MockReferralUserResponse.Full.object
        #expect(referralUserResponse == expectedReferralUserResponse)
    }
}
