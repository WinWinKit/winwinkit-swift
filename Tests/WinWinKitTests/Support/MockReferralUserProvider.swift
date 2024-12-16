//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralUserProvider.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
@testable import WinWinKit

enum MockReferralUserProviderError: Error {
    case noReferralUserToReturn
}

final class MockReferralUserProvider: ReferralUserProviderType {

    var referralUserToReturn: ReferralUser? = nil
    
    func fetch(appUserId: String, projectKey: String) async throws -> ReferralUser? {
        self.referralUserToReturn
    }
    
    func create(referralUser: InsertReferralUser, projectKey: String) async throws -> ReferralUser {
        if let referralUserToReturn {
            return referralUserToReturn
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
    
    func update(referralUser: UpdateReferralUser, projectKey: String) async throws -> ReferralUser {
        if let referralUserToReturn {
            return referralUserToReturn
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
    
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralUser {
        if let referralUserToReturn {
            return referralUserToReturn
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
}
