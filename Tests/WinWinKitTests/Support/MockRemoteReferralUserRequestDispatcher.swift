//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockRemoteReferralUserRequestDispatcher.swift
//
//  Created by Oleh Stasula on 17/12/2024.
//

import Foundation
@testable import WinWinKit

struct MockRemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    let referralUserToReturn: ReferralUser?
    let errorToThrow: Error?
    
    func perform(request: RemoteReferralUserRequest) async throws -> RemoteReferralUserResponse? {
        if let errorToThrow {
            throw errorToThrow
        }
        return self.referralUserToReturn.map { RemoteReferralUserResponse(data: $0) }
    }
}
