//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  AppStoreTransactionsProvider.swift
//

protocol AppStoreTransactionsProviderType {
    func registerTransaction(request: UserRegisterAppStoreTransactionRequest, appUserId: String, apiKey: String) async throws
}

struct AppStoreTransactionsProvider: AppStoreTransactionsProviderType {
    func registerTransaction(request: UserRegisterAppStoreTransactionRequest, appUserId: String, apiKey: String) async throws {
        try await UsersAPI.registerAppStoreTransaction(appUserId: appUserId, xApiKey: apiKey, userRegisterAppStoreTransactionRequest: request)
    }
}
