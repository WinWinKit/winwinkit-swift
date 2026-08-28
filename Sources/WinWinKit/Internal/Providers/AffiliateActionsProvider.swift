//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  AffiliateActionsProvider.swift
//
//  Created by Oleh Stasula on 28/08/2026.
//

protocol AffiliateActionsProviderType {
    func createApplyLink(request: UserAffiliateApplyLinkRequest, appUserId: String, apiKey: String) async throws -> UserAffiliateApplyLinkResponseData
}

struct AffiliateActionsProvider: AffiliateActionsProviderType {
    func createApplyLink(request: UserAffiliateApplyLinkRequest, appUserId: String, apiKey: String) async throws -> UserAffiliateApplyLinkResponseData {
        try await UsersAPI.createAffiliateApplyLink(appUserId: appUserId, xApiKey: apiKey, userAffiliateApplyLinkRequest: request).data
    }
}
