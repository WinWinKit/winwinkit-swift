//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockRewardActionsProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation
@testable import WinWinKit

final class MockRewardActionsProvider: RewardActionsProviderType {
    var grantRewardResultToReturn: Result<UserGrantRewardResponseData, Error>? = nil
    var grantRewardCallsCounter: Int = 0

    var grantRewardRequest: UserGrantRewardRequest? = nil
    var grantRewardAppUserId: String? = nil
    var grantRewardApiKey: String? = nil

    var withdrawCreditsResultToReturn: Result<UserWithdrawCreditsResponseData, Error>? = nil
    var withdrawCreditsCallsCounter: Int = 0

    var request: UserWithdrawCreditsRequest? = nil
    var appUserId: String? = nil
    var apiKey: String? = nil

    func grantReward(request: UserGrantRewardRequest, appUserId: String, apiKey: String) async throws -> UserGrantRewardResponseData {
        self.grantRewardRequest = request
        self.grantRewardAppUserId = appUserId
        self.grantRewardApiKey = apiKey
        self.grantRewardCallsCounter += 1

        switch self.grantRewardResultToReturn {
        case let .success(userGrantRewardResponse):
            return userGrantRewardResponse
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }

    func withdrawCredits(request: UserWithdrawCreditsRequest, appUserId: String, apiKey: String) async throws -> UserWithdrawCreditsResponseData {
        self.request = request
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.withdrawCreditsCallsCounter += 1

        switch self.withdrawCreditsResultToReturn {
        case let .success(userWithdrawCreditsResponse):
            return userWithdrawCreditsResponse
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
