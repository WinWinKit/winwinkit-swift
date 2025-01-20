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
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: MockReferralUser.Full.object,
                                                                  errorToThrow: nil)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        let result = try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        #expect(result?.appUserId == "app-user-id-1")
    }
    
    @Test func fetchNotFound() async throws {
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: nil,
                                                                  errorToThrow: RemoteRequestDispatcherError.notFound)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        let result = try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        #expect(result == nil)
    }
    
    @Test func fetchUnauthorized() async throws {
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: nil,
                                                                  errorToThrow: RemoteRequestDispatcherError.unauthorized)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        
        await #expect(throws: RemoteRequestDispatcherError.unauthorized) {
            try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        }
    }
    
    @Test func fetchUnknown() async throws {
        let baseEndpointURL = URL(string: "https://api.winwinkit.com")!
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: nil,
                                                                  errorToThrow: RemoteRequestDispatcherError.unknown)
        let provider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        
        await #expect(throws: RemoteRequestDispatcherError.unknown) {
            try await provider.fetch(appUserId: "app-user-id-1", projectKey: "project-key-1")
        }
    }
}
