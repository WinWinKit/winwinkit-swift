//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralUserData.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation

enum ReferralUserData {
    static let referralUser1: Data = """
            {
                "data": { 
                    "app_user_id": "app-user-id-1",
                    "code": "XYZ123",
                    "is_premium": true,
                    "first_seen_at": "2024-12-05T08:47:11.782+00:00",
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
            .data(using: .utf8)!
}
