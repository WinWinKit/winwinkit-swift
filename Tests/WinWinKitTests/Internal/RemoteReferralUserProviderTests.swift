//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserProviderTests.swift
//
//  Created by Oleh Stasula on 17/12/2024.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct RemoteReferralUserProviderTests {
    
    @Test func fetchSuccess() async throws {
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let requestDispatcher = MockRemoteReferralUserRequestDispatcher(referralUserToReturn: MockReferralUser.referralUser1,
                                                                        errorToThrow: nil)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  referralUserRequestDispatcher: requestDispatcher)
        let result = try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        #expect(result?.appUserId == "app-user-id-1")
    }
    
    @Test func fetchNotFound() async throws {
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let requestDispatcher = MockRemoteReferralUserRequestDispatcher(referralUserToReturn: nil,
                                                                        errorToThrow: RemoteReferralUserRequestDispatcherError.notFound)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  referralUserRequestDispatcher: requestDispatcher)
        let result = try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        #expect(result == nil)
    }
}
