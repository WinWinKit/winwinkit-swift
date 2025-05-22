//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockClaimActionsProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation
@testable import WinWinKit

final class MockClaimActionsProvider: ClaimActionsProviderType {
    var claimReferralCodeResultToReturn: Result<UserClaimReferralCodeResponse, Error>? = nil
    var claimReferralCodeCallsCounter: Int = 0

    var request: UserClaimReferralCodeRequest? = nil
    var appUserId: String? = nil
    var apiKey: String? = nil

    func claimReferralCode(request: UserClaimReferralCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimReferralCodeResponse {
        self.request = request
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.claimReferralCodeCallsCounter += 1

        switch self.claimReferralCodeResultToReturn {
        case let .success(userClaimReferralCodeResponse):
            return userClaimReferralCodeResponse
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
