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

import Testing
@testable import WinWinKit

@Suite struct RemoteReferralUserProviderTests {
    
    @Test func fetchSuccess() async throws {
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: MockReferralUser.Full.object,
                                                                  errorToThrow: nil)
        let provider = RemoteReferralUserProvider(baseEndpointURL: MockConstants.baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        let result = try await provider.fetch(appUserId: MockReferralUser.Full.object.appUserId,
                                              projectKey: MockConstants.projectKey)
        #expect(result == MockReferralUser.Full.object)
    }
    
    @Test func fetchNil() async throws {
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: nil,
                                                                  errorToThrow: nil)
        let provider = RemoteReferralUserProvider(baseEndpointURL: MockConstants.baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        let result = try await provider.fetch(appUserId: MockReferralUser.Full.object.appUserId,
                                              projectKey: MockConstants.projectKey)
        #expect(result == nil)
    }
    
    @Test func fetchNotFound() async throws {
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: MockReferralUser.Full.object,
                                                                  errorToThrow: RemoteRequestDispatcherError.notFound)
        let provider = RemoteReferralUserProvider(baseEndpointURL: MockConstants.baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        let result = try await provider.fetch(appUserId: MockReferralUser.Full.object.appUserId,
                                              projectKey: MockConstants.projectKey)
        #expect(result == nil)
    }
    
    @Test func fetchUnauthorized() async throws {
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: MockReferralUser.Full.object,
                                                                  errorToThrow: RemoteRequestDispatcherError.unauthorized)
        let provider = RemoteReferralUserProvider(baseEndpointURL: MockConstants.baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        
        await #expect(throws: RemoteRequestDispatcherError.unauthorized) {
            try await provider.fetch(appUserId: MockReferralUser.Full.object.appUserId,
                                     projectKey: MockConstants.projectKey)
        }
    }
    
    @Test func fetchUnknown() async throws {
        let remoteRequestDispatcher = MockRemoteRequestDispatcher(referralUserToReturn: MockReferralUser.Full.object,
                                                                  errorToThrow: RemoteRequestDispatcherError.unknown)
        let provider = RemoteReferralUserProvider(baseEndpointURL: MockConstants.baseEndpointURL,
                                                  remoteRequestDispatcher: remoteRequestDispatcher)
        
        await #expect(throws: RemoteRequestDispatcherError.unknown) {
            try await provider.fetch(appUserId: MockReferralUser.Full.object.appUserId,
                                     projectKey: MockConstants.projectKey)
        }
    }
}
