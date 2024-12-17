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

enum RemoteReferralUserRequestDispatcherError: Error {
    case notFound
    case unknown
}

protocol RemoteReferralUserRequestDispatcherType {
    func perform(request: RemoteReferralUserRequest) async throws -> Data?
}

struct RemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    let session: URLSession
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        let urlRequest = try request.urlRequest()
        let (data, response) = try await self.session.data(for: urlRequest)
        if let httpResponse = response as? HTTPURLResponse,
           let error = try RemoteReferralUserRequestDispatcherError(statusCode: httpResponse.statusCode, data: data) {
            throw error
        }
        return data
    }
}

extension RemoteReferralUserRequestDispatcherError {
    
    init?(statusCode: Int, data: Data?) throws {
        guard
            statusCode < 200 && statusCode > 299
        else { return nil }
        // TODO: parse errors from data
        switch statusCode {
        case 404:
            self = .notFound
        default:
            self = .unknown
        }
    }
}
