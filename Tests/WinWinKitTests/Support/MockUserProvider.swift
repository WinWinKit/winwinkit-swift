//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockUserProvider.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
@testable import WinWinKit

enum MockUserProviderError: Error {
    case noUserToReturn
}

final class MockUserProvider: UserProviderType {
    var userToReturn: User? = nil
    var errorToThrow: Error? = nil
    var createOrUpdateMethodCallsCounter: Int = 0

    func createOrUpdate(request _: UserCreateRequest, apiKey _: String) async throws -> User {
        self.createOrUpdateMethodCallsCounter += 1
        if let errorToThrow {
            throw errorToThrow
        }
        if let userToReturn {
            return userToReturn
        }
        throw MockUserProviderError.noUserToReturn
    }
}
