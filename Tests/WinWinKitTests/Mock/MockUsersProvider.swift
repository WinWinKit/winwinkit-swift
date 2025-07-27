//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockUsersProvider.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
@testable import WinWinKit

final class MockUsersProvider: UsersProviderType {
    var createOrUpdateUserResultToReturn: Result<UserResponseData, Error>? = nil
    var createOrUpdateUserCallsCounter: Int = 0

    var request: UserCreateRequest? = nil
    var apiKey: String? = nil

    func createOrUpdateUser(request: UserCreateRequest, apiKey: String) async throws -> UserResponseData {
        self.request = request
        self.apiKey = apiKey
        self.createOrUpdateUserCallsCounter += 1

        switch self.createOrUpdateUserResultToReturn {
        case let .success(user):
            return user
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
