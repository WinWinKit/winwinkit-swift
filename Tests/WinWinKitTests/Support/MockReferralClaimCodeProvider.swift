//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralClaimCodeProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation
@testable import WinWinKit

enum MockReferralClaimCodeProviderError: Error {
    case noReferralUserToReturn
}

final class MockReferralClaimCodeProvider: ReferralClaimCodeProviderType {
    
    var referralClaimCodeResultToReturn: ReferralClaimCodeResult? = nil
    var errorToThrow: Error? = nil
    var claimMethodCallsCounter: Int = 0
    
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralClaimCodeResult {
        self.claimMethodCallsCounter += 1
        if let errorToThrow {
            throw errorToThrow
        }
        if let referralClaimCodeResultToReturn {
            return referralClaimCodeResultToReturn
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
}
