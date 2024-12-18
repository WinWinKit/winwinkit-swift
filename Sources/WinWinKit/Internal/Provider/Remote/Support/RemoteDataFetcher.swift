//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteDataFetcher.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation

enum RemoteDataFetcherError: Error {
    case unableToExtractResponseStatusCode
}

protocol RemoteDataFetcherType {
    func data(for urlRequest: URLRequest) async throws -> (Int, Data?)
}

struct RemoteDataFetcher: RemoteDataFetcherType {
    
    let session: URLSession
    
    // MARK: - RemoteDataFetcherType
    
    func data(for urlRequest: URLRequest) async throws -> (Int, Data?) {
        let (data, response) = try await self.session.data(for: urlRequest)
        guard
            let httpResponse = response as? HTTPURLResponse
        else {
            throw RemoteDataFetcherError.unableToExtractResponseStatusCode
        }
        return (httpResponse.statusCode, data)
    }
}
