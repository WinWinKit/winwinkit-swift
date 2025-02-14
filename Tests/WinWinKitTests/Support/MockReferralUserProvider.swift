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

    var referralUserToReturnOnFetch: ReferralUser? = nil
    var errorToThrowOnFetch: Error? = nil
    var fetchMethodCallsCounter: Int = 0
    
    var referralUserToReturnOnCreate: ReferralUser? = nil
    var errorToThrowOnCreate: Error? = nil
    var createMethodCallsCounter: Int = 0
    
    var referralUserToReturnOnClaim: ReferralUser? = nil
    var errorToThrowOnClaim: Error? = nil
    var claimMethodCallsCounter: Int = 0
    
    func fetch(appUserId: String, projectKey: String) async throws -> ReferralUser? {
        self.fetchMethodCallsCounter += 1
        if let errorToThrowOnFetch {
            throw errorToThrowOnFetch
        }
        return self.referralUserToReturnOnFetch
    }
    
    func createOrUpdate(referralUser: ReferralUserUpdate, projectKey: String) async throws -> ReferralUser {
        self.createMethodCallsCounter += 1
        if let errorToThrowOnCreate {
            throw errorToThrowOnCreate
        }
        if let referralUserToReturnOnCreate {
            return referralUserToReturnOnCreate
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
    
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralUser {
        self.claimMethodCallsCounter += 1
        if let errorToThrowOnClaim {
            throw errorToThrowOnClaim
        }
        if let referralUserToReturnOnClaim {
            return referralUserToReturnOnClaim
        }
        throw MockReferralUserProviderError.noReferralUserToReturn
    }
}
