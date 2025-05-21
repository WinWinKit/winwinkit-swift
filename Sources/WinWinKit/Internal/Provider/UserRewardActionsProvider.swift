//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserRewardActionsProvider.swift
//
//  Created by Oleh Stasula on 21/05/2025.
//

protocol UserRewardActionsProviderType {
    func withdrawCredits(request: UserWithdrawCreditsRequest, appUserId: String, apiKey: String) async throws -> UserWithdrawCreditsResponse
}

struct UserRewardActionsProvider: UserRewardActionsProviderType {
    func withdrawCredits(request: UserWithdrawCreditsRequest, appUserId: String, apiKey: String) async throws -> UserWithdrawCreditsResponse {
        try await RewardsActionsAPI.withdrawCredits(appUserId: appUserId, xApiKey: apiKey, userWithdrawCreditsRequest: request).data
    }
}
