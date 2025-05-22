//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UsersProvider.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

protocol UsersProviderType {
    func createOrUpdateUser(request: UserCreateRequest, apiKey: String) async throws -> User
}

struct UsersProvider: UsersProviderType {
    func createOrUpdateUser(request: UserCreateRequest, apiKey: String) async throws -> User {
        try await UsersAPI.createOrUpdateUser(xApiKey: apiKey, userCreateRequest: request).data.user
    }
}
