//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockUserClaimActionsProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation
@testable import WinWinKit

enum MockUserClaimActionsProviderError: Error {
    case noUserClaimActionsResultToReturn
}

final class MockUserClaimActionsProvider: UserClaimActionsProviderType {
    var userClaimActionsResultToReturn: UserClaimReferralCodeResponse? = nil
    var errorToThrow: Error? = nil
    var claimMethodCallsCounter: Int = 0

    func claim(referralCode _: UserClaimReferralCodeRequest, appUserId _: String, apiKey _: String) async throws -> UserClaimReferralCodeResponse {
        self.claimMethodCallsCounter += 1
        if let errorToThrow {
            throw errorToThrow
        }
        if let userClaimActionsResultToReturn {
            return userClaimActionsResultToReturn
        }
        throw MockUserClaimActionsProviderError.noUserClaimActionsResultToReturn
    }
}
