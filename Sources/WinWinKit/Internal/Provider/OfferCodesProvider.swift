//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  OfferCodesProvider.swift
//
//  Created by Oleh Stasula on 20/05/2025.
//

protocol OfferCodesProviderType {
    func fetchOfferCode(offerCodeId: String, apiKey: String) async throws -> OfferCodeResponse
}

struct OfferCodesProvider: OfferCodesProviderType {
    func fetchOfferCode(offerCodeId: String, apiKey: String) async throws -> OfferCodeResponse {
        try await AppStoreAPI.getOfferCode(offerCodeId: offerCodeId, xApiKey: apiKey).data
    }
}
