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
    var claimCodeResultToReturn: Result<UserClaimCodeResponseData, Error>? = nil
    var claimCodeCallsCounter: Int = 0

    var request: UserClaimCodeRequest? = nil
    var appUserId: String? = nil
    var apiKey: String? = nil

    func claimCode(request: UserClaimCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimCodeResponseData {
        self.request = request
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.claimCodeCallsCounter += 1

        switch self.claimCodeResultToReturn {
        case let .success(userClaimCodeResponse):
            return userClaimCodeResponse
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
