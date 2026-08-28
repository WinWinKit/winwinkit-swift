//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockAffiliateActionsProvider.swift
//
//  Created by Oleh Stasula on 28/08/2026.
//

import Foundation
@testable import WinWinKit

final class MockAffiliateActionsProvider: AffiliateActionsProviderType {
    var createApplyLinkResultToReturn: Result<UserAffiliateApplyLinkResponseData, Error>? = nil
    var createApplyLinkCallsCounter: Int = 0

    var request: UserAffiliateApplyLinkRequest? = nil
    var appUserId: String? = nil
    var apiKey: String? = nil

    func createApplyLink(request: UserAffiliateApplyLinkRequest, appUserId: String, apiKey: String) async throws -> UserAffiliateApplyLinkResponseData {
        self.request = request
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.createApplyLinkCallsCounter += 1

        switch self.createApplyLinkResultToReturn {
        case let .success(userAffiliateApplyLinkResponse):
            return userAffiliateApplyLinkResponse
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
