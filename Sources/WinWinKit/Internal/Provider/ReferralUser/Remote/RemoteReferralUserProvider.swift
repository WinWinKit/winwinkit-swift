//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserProvider.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

enum RemoteReferralUserProviderError: Error {
    case receivedNoDataOnCreateOrUpdate
}

struct RemoteReferralUserProvider: ReferralUserProviderType {
    
    let baseEndpointURL: URL
    let remoteRequestDispatcher: RemoteRequestDispatcherType
    
    // MARK: - ReferralUserProviderType
    
    func fetch(appUserId: String, apiKey: String) async throws -> ReferralUser? {
        do {
            return try await self.perform(request: .get(appUserId: appUserId),
                                          apiKey: apiKey)
        }
        catch (let error as RemoteRequestDispatcherError) {
            if error == .notFound {
                return nil
            }
            throw error
        }
        catch {
            throw error
        }
    }
    
    func createOrUpdate(referralUser: ReferralUserUpdate, apiKey: String) async throws -> ReferralUser {
        try await self.perform(request: .post(user: referralUser),
                               apiKey: apiKey)
            .unwrap(orThrow: .receivedNoDataOnCreateOrUpdate)
    }
    
    // MARK: - Private
    
    private func perform(request: RemoteReferralUserRequest.Request, apiKey: String) async throws -> ReferralUser? {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                apiKey: apiKey,
                                                request: request)
        let response: RemoteReferralUserResponse? = try await self.remoteRequestDispatcher.perform(request: request)
        let referralUser = response?.data?.referralUser
        return referralUser
    }
}

extension Optional where Wrapped == ReferralUser {
    
    fileprivate func unwrap(orThrow error: RemoteReferralUserProviderError) throws -> ReferralUser {
        if let self {
            return self
        }
        throw error
    }
}
