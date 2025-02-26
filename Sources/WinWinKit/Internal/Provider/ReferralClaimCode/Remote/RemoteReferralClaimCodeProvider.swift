//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralClaimCodeProvider.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

enum RemoteReferralClaimCodeProviderError: Error {
    case receivedNoDataOnClaimCode
}

struct RemoteReferralClaimCodeProvider: ReferralClaimCodeProviderType {
    
    let baseEndpointURL: URL
    let remoteRequestDispatcher: RemoteRequestDispatcherType
    
    // MARK: - ReferralUserProviderType
    
    func claim(code: String, appUserId: String, apiKey: String) async throws -> ReferralClaimCodeResult {
        try await self.perform(request: .claim(code: code, appUserId: appUserId),
                               apiKey: apiKey)
            .unwrap(orThrow: .receivedNoDataOnClaimCode)
    }
    
    // MARK: - Private
    
    private func perform(request: RemoteReferralClaimCodeRequest.Request, apiKey: String) async throws -> ReferralClaimCodeResult? {
        let request = RemoteReferralClaimCodeRequest(baseEndpointURL: self.baseEndpointURL,
                                                     apiKey: apiKey,
                                                     request: request)
        let response: RemoteReferralClaimCodeResponse? = try await self.remoteRequestDispatcher.perform(request: request)
        guard
            let data = response?.data
        else { return nil }
        
        return ReferralClaimCodeResult(
            referralUser: data.referralUser,
            grantedRewards: data.grantedRewards
        )
    }
}

extension Optional where Wrapped == ReferralClaimCodeResult {
    
    fileprivate func unwrap(orThrow error: RemoteReferralClaimCodeProviderError) throws -> ReferralClaimCodeResult {
        if let self {
            return self
        }
        throw error
    }
}
