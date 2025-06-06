//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ClaimActionsProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

protocol ClaimActionsProviderType {
    func claimReferralCode(request: UserClaimReferralCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimReferralCodeResponse
}

struct ClaimActionsProvider: ClaimActionsProviderType {
    func claimReferralCode(request: UserClaimReferralCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimReferralCodeResponse {
        try await ClaimActionsAPI.claimReferralCode(appUserId: appUserId, xApiKey: apiKey, userClaimReferralCodeRequest: request).data
    }
}
