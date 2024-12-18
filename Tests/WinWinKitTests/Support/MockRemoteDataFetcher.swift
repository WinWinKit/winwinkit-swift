//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockRemoteDataFetcher.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation
@testable import WinWinKit

struct MockRemoteDataFetcher: RemoteDataFetcherType {
    
    let responseToReturn: (Int, Data?)
    let errorToThrow: Error?
    
    func data(for urlRequest: URLRequest) async throws -> (Int, Data?) {
        if let errorToThrow {
            throw errorToThrow
        }
        return self.responseToReturn
    }
}
