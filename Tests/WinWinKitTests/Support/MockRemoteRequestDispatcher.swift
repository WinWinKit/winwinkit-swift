//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockRemoteRequestDispatcher.swift
//
//  Created by Oleh Stasula on 17/12/2024.
//

import Foundation
@testable import WinWinKit

struct MockRemoteRequestDispatcher: RemoteRequestDispatcherType {
    
    let referralUserToReturn: ReferralUser?
    let errorToThrow: Error?
    
    func perform<Response: Codable>(request: any RemoteRequest) async throws -> Response? {
        if let errorToThrow {
            throw errorToThrow
        }
        return self.referralUserToReturn.map { RemoteReferralUserResponse(data: $0) } as? Response
    }
}
