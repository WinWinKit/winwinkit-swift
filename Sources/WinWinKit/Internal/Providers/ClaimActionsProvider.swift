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
    func claimCode(request: UserClaimCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimCodeResponse
}

struct ClaimActionsProvider: ClaimActionsProviderType {
    func claimCode(request: UserClaimCodeRequest, appUserId: String, apiKey: String) async throws -> UserClaimCodeResponse {
        try await ClaimActionsAPI.claimCode(appUserId: appUserId, xApiKey: apiKey, userClaimCodeRequest: request).data
    }
}
