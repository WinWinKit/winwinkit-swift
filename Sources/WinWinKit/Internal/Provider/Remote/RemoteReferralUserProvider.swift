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
    case receivedNoDataOnClaimCode
}

struct RemoteReferralUserProvider: ReferralUserProviderType {
    
    let baseEndpointURL: URL
    let requestDispatcher: RemoteReferralUserRequestDispatcherType
    
    // MARK: - ReferralUserProviderType
    
    func fetch(appUserId: String, projectKey: String) async throws -> ReferralUser? {
        try await self.perform(request: .get(appUserId: appUserId),
                               projectKey: projectKey)
    }
    
    func create(referralUser: InsertReferralUser, projectKey: String) async throws -> ReferralUser {
        try await self.perform(request: .post(user: referralUser),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnCreate)
    }
    
    func update(referralUser: UpdateReferralUser, projectKey: String) async throws -> ReferralUser {
        try await self.perform(request: .patch(user: referralUser),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnUpdate)
    }
    
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralUser {
        try await self.perform(request: .claim(code: code, appUserId: appUserId),
                               projectKey: projectKey)
            .unwrap(orThrow: .receivedNoDataOnClaimCode)
    }
    
    // MARK: - Private
    
    private func perform(request: RemoteReferralUserRequest.Request, projectKey: String) async throws -> ReferralUser? {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                projectKey: projectKey,
                                                request: request)
        let data = try await self.requestDispatcher.perform(request: request)
        let referralUser = try data.map { try RemoteReferralUserDataResponse(jsonData: $0) }?.data
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
