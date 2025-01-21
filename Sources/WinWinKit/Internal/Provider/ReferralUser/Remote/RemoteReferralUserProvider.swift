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
    case receivedNoDataOnCreate
    case receivedNoDataOnUpdate
}

struct RemoteReferralUserProvider: ReferralUserProviderType {
    
    let baseEndpointURL: URL
    let remoteRequestDispatcher: RemoteRequestDispatcherType
    
    // MARK: - ReferralUserProviderType
    
    func fetch(appUserId: String, projectKey: String) async throws -> ReferralUser? {
        do {
            return try await self.perform(request: .get(appUserId: appUserId),
                                          projectKey: projectKey)
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
    
    func create(referralUser: ReferralUserInsert, projectKey: String) async throws -> ReferralUser {
        try await self.perform(request: .post(user: referralUser),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnCreate)
    }
    
    func update(referralUser: ReferralUserUpdate, projectKey: String) async throws -> ReferralUser {
        try await self.perform(request: .patch(user: referralUser),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnUpdate)
    }
    
    // MARK: - Private
    
    private func perform(request: RemoteReferralUserRequest.Request, projectKey: String) async throws -> ReferralUser? {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                projectKey: projectKey,
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
