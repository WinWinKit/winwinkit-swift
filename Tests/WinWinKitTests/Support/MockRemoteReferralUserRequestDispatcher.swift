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

struct MockSuccessfulRemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        switch request.request {
        case .get(let appUserId):
            return
                """
                {
                    "data": { 
                        "app_user_id": "\(appUserId)",
                        "code": "XYZ123",
                        "is_premium": true,
                        "user_since": "2024-12-05T08:47:11.782+00:00",
                        "last_seen_at": null,
                        "metadata": {
                            "1": 123
                        },
                        "program": null,
                        "rewards": {
                            "basic": [],
                            "credit": []
                        }
                    }
                }
                """
                .data(using: .utf8)
        case .post(let user):
            return nil
        case .patch(let user):
            return nil
        case .claim(let code, let appUserId):
            return nil
        }
    }
}

struct MockFailingRemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        return
            """
            {
                "errors": {
                    "formErrors": [
                        "Error!"
                    ],
                    "fieldErrors": []
                }
            }
            """
            .data(using: .utf8)
    }
}

struct MockThrowingRemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    let errorToThrow: Error
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        throw self.errorToThrow
    }
}

struct MockNilRemoteReferralUserRequestDispatcher: RemoteReferralUserRequestDispatcherType {
    
    func perform(request: RemoteReferralUserRequest) async throws -> Data? {
        nil
    }
}
