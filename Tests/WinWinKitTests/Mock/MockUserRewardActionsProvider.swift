//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockUserRewardActionsProvider.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation
@testable import WinWinKit

enum MockUserRewardActionsProviderError: Error {
    case noUserWithdrawCreditsResultToReturn
}

final class MockUserRewardActionsProvider: UserRewardActionsProviderType {
    var userWithdrawCreditsResultToReturn: UserWithdrawCreditsResponse? = nil
    var errorToThrow: Error? = nil
    var withdrawMethodCallsCounter: Int = 0

    func withdrawCredits(request: UserWithdrawCreditsRequest, appUserId _: String, apiKey _: String) async throws -> UserWithdrawCreditsResponse {
        self.withdrawMethodCallsCounter += 1
        if let errorToThrow {
            throw errorToThrow
        }
        if let userWithdrawCreditsResultToReturn {
            return userWithdrawCreditsResultToReturn
        }
        throw MockUserRewardActionsProviderError.noUserWithdrawCreditsResultToReturn
    }
}
