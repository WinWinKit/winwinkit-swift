//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserRequestDispatcher.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

protocol RemoteReferralUserRequestDispatcherType {
    func perform(request: RemoteReferralUserRequest) async throws -> Data?
}

struct RemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    let session: URLSession
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        let urlRequest = try request.urlRequest()
        let (result, response) = try await self.session.data(for: urlRequest)
        return result
    }
}
