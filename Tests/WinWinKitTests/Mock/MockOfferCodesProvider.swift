//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockOfferCodesProvider.swift
//
//  Created by Oleh Stasula on 20/05/2025.
//

import Foundation
@testable import WinWinKit

final class MockOfferCodesProvider: OfferCodesProviderType {
    var fetchOfferCodeResultToReturn: Result<OfferCodeResponseData, Error>? = nil
    var fetchOfferCodeCallsCounter: Int = 0

    var offerCodeId: String? = nil
    var apiKey: String? = nil

    func fetchOfferCode(offerCodeId: String, apiKey: String) async throws -> OfferCodeResponseData {
        self.offerCodeId = offerCodeId
        self.apiKey = apiKey
        self.fetchOfferCodeCallsCounter += 1

        switch self.fetchOfferCodeResultToReturn {
        case let .success(offerCode):
            return offerCode
        case let .failure(error):
            throw error
        case .none:
            throw MockError(message: "Nothing to return")
        }
    }
}
