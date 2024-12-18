//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteRequestDispatcher.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation

enum RemoteRequestDispatcherError: Error {
    case unableToExtractResponseStatusCode
}

protocol RemoteRequestDispatcherType {
    func perform(request: RemoteReferralUserRequest) async throws -> (Int, Data?)
}

struct RemoteRequestDispatcher: RemoteRequestDispatcherType {
    
    let session: URLSession
    
    // MARK: - RemoteRequestDispatcherType
    
    func perform(request: RemoteReferralUserRequest) async throws -> (Int, Data?) {
        let urlRequest = try request.urlRequest()
        let (data, response) = try await self.session.data(for: urlRequest)
        guard
            let httpResponse = response as? HTTPURLResponse
        else {
            throw RemoteRequestDispatcherError.unableToExtractResponseStatusCode
        }
        return (httpResponse.statusCode, data)
    }
}
