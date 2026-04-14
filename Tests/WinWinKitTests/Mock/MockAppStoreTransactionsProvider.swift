//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockAppStoreTransactionsProvider.swift
//

import Foundation
@testable import WinWinKit

final class MockAppStoreTransactionsProvider: AppStoreTransactionsProviderType {
    var registerTransactionResultToReturn: Result<Void, Error>? = nil
    var registerTransactionCallsCounter: Int = 0

    var request: UserRegisterAppStoreTransactionRequest? = nil
    var appUserId: String? = nil
    var apiKey: String? = nil

    func registerTransaction(request: UserRegisterAppStoreTransactionRequest, appUserId: String, apiKey: String) async throws {
        self.request = request
        self.appUserId = appUserId
        self.apiKey = apiKey
        self.registerTransactionCallsCounter += 1

        switch self.registerTransactionResultToReturn {
        case .success:
            return
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
