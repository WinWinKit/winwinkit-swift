//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteRequestDispatcherTests.swift
//
//  Created by Oleh Stasula on 26/01/2025.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct RemoteRequestDispatcherTests {
    
    @Test func unauthorized() async throws {
        let remoteDataFetcher = RemoteDataFetcher(session: .shared)
        let dispatcher = RemoteRequestDispatcher(remoteDataFetcher: remoteDataFetcher)
        let request = RemoteReferralUserRequest(baseEndpointURL: MockConstants.baseEndpointURL,
                                                projectKey: MockConstants.projectKey,
                                                request: .get(appUserId: MockReferralUser.Full.object.appUserId))
        await #expect(throws: RemoteRequestDispatcherError.unauthorized) {
            let _: RemoteReferralUserResponse? = try await dispatcher.perform(request: request)
        }
    }
}
