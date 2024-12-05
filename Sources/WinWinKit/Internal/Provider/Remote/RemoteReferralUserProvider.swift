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
    case missingReferralUserAfterCreation
    case missingReferralUserAfterUpdate
}

struct RemoteReferralUserProvider: ReferralUserProviderType {
    
    let baseEndpointURL: URL
    let requestDispatcher: RemoteReferralUserRequestDispatcherType
    
    // MARK: - ReferralUserProviderType
    
    func fetch(userId: ReferralUser.ID, projectKey: String) async throws -> ReferralUser? {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                projectKey: projectKey,
                                                request: .get(userId: userId))
        let data = try await self.requestDispatcher.perform(request: request)
        let referralUser = try data.map {
            try JSONDecoder().decode(ReferralUser.self, from: $0)
        }
        return referralUser
    }
    
    func create(referralUser: InsertReferralUser, projectKey: String) async throws -> ReferralUser {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                projectKey: projectKey,
                                                request: .post(user: referralUser))
        let data = try await self.requestDispatcher.perform(request: request)
        let referralUser = try data.map {
            try JSONDecoder().decode(ReferralUser.self, from: $0)
        }
        guard let referralUser else {
            throw RemoteReferralUserProviderError.missingReferralUserAfterCreation
        }
        return referralUser
    }
    
    func update(referralUser: UpdateReferralUser, projectKey: String) async throws -> ReferralUser {
        let request = RemoteReferralUserRequest(baseEndpointURL: self.baseEndpointURL,
                                                projectKey: projectKey,
                                                request: .patch(user: referralUser))
        let data = try await self.requestDispatcher.perform(request: request)
        let referralUser = try data.map {
            try JSONDecoder().decode(ReferralUser.self, from: $0)
        }
        guard let referralUser else {
            throw RemoteReferralUserProviderError.missingReferralUserAfterUpdate
        }
        return referralUser
    }
}
