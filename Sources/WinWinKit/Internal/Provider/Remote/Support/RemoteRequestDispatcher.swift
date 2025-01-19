//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteRequestDispatcher.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

enum RemoteRequestDispatcherError: Error {
    case notFound
    case unauthorized
    case unknown
}

protocol RemoteRequestDispatcherType {
    func perform<Response: Codable>(request: RemoteRequest) async throws -> Response?
}

struct RemoteRequestDispatcher: RemoteRequestDispatcherType {
    
    let remoteDataFetcher: RemoteDataFetcherType
    
    // MARK: - RemoteRequestDispatcherType
    
    func perform<Response: Codable>(request: RemoteRequest) async throws -> Response? {
        let urlRequest = try request.urlRequest()
        let (statusCode, data) = try await self.remoteDataFetcher.data(for: urlRequest)
        if let error = try RemoteRequestDispatcherError(statusCode: statusCode, data: data) {
            throw error
        }
        let response = try data.map { try Response(jsonData: $0) }
        return response
    }
}

extension RemoteRequestDispatcherError {
    
    init?(statusCode: Int, data: Data?) throws {
        guard
            statusCode < 200 && statusCode > 299
        else { return nil }
        // TODO: parse errors from data
        switch statusCode {
        case 404:
            self = .notFound
        case 401:
            self = .unauthorized
        default:
            self = .unknown
        }
    }
}
