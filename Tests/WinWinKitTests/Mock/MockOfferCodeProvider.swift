//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockOfferCodeProvider.swift
//
//  Created by Oleh Stasula on 20/05/2025.
//

import Foundation
@testable import WinWinKit

enum MockOfferCodeProviderError: Error {
    case noOfferCodeToReturn
}

final class MockOfferCodeProvider: OfferCodeProviderType {
    var offerCodeToReturn: OfferCodeResponse? = nil
    var errorToThrow: Error? = nil
    var fetchMethodCallsCounter: Int = 0

    func fetch(offerCodeId _: String, apiKey _: String) async throws -> OfferCodeResponse {
        self.fetchMethodCallsCounter += 1
        if let errorToThrow {
            throw errorToThrow
        }
        if let offerCodeToReturn {
            return offerCodeToReturn
        }
        throw MockOfferCodeProviderError.noOfferCodeToReturn
    }
}
