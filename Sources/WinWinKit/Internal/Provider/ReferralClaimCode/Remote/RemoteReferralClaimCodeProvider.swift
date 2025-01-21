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
    
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralClaimCodeData {
        try await self.perform(request: .claim(code: code, appUserId: appUserId),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnClaimCode)
    }
    
    // MARK: - Private
    
    private func perform(request: RemoteReferralClaimCodeRequest.Request, projectKey: String) async throws -> ReferralClaimCodeData? {
        let request = RemoteReferralClaimCodeRequest(baseEndpointURL: self.baseEndpointURL,
                                                     projectKey: projectKey,
                                                     request: request)
        let response: RemoteReferralClaimCodeResponse? = try await self.remoteRequestDispatcher.perform(request: request)
        guard
            let data = response?.data
        else { return nil }
        
        return ReferralClaimCodeData(
            referralUser: data.referralUser,
            referralGrantedRewards: data.grantedRewards
        )
    }
}

extension Optional where Wrapped == ReferralClaimCodeData {
    
    fileprivate func unwrap(orThrow error: RemoteReferralClaimCodeProviderError) throws -> ReferralClaimCodeData {
        if let self {
            return self
        }
        throw error
    }
}
