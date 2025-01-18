//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserCodableTests.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct ReferralUserCodableTests {
    
    @Test func encoding() throws {
        let jsonString = """
            {
                "app_user_id": "app-user-id-1",
                "code": "XYZ123",
                "is_premium": true,
                "first_seen_at": "2020-12-06T11:15:59.000000+00:00",
                "last_seen_at": "2024-12-06T11:15:59.000000+00:00",
                "metadata": {
                    "1": 123
                },
                "program": {
                    "id": "j34me52cznsa2wt6xwbgfimp",
                    "name": "Program #1",
                    "description": null,
                    "distribution_percentage": 0,
                    "limit": 0,
                    "metadata": null,
                    "rewards": {
                        "sender": {
                            "basic": [],
                            "credit": []
                        },
                        "receiver": {
                            "basic": [],
                            "credit": []
                        }
                    }
                },
                "rewards": {
                    "active": {
                        "basic": [],
                        "credit": [],
                    }
                },
                "stats": {
                    "claims": 10,
                    "conversions": 8,
                    "churns": 2
                }
            }
        """
        let jsonData = jsonString.data(using: .utf8)!
        let referralUser = try ReferralUser(jsonData: jsonData)
        #expect(referralUser.appUserId == "app-user-id-1")
        #expect(referralUser.code == "XYZ123")
        #expect(referralUser.isPremium == true)
        #expect(referralUser.firstSeenAt == Date(timeIntervalSince1970: 1607253359))
        #expect(referralUser.lastSeenAt == Date(timeIntervalSince1970: 1733483759))
        #expect(referralUser.metadata == ["1": 123])
        #expect(referralUser.program == ReferralUser.ReferralProgram(id: "j34me52cznsa2wt6xwbgfimp",
                                                                     name: "Program #1",
                                                                     description: nil,
                                                                     distributionPercentage: 0,
                                                                     limit: 0,
                                                                     metadata: nil,
                                                                     rewards: ReferralUser.ReferralProgram.Rewards(sender: ReferralUser.ReferralProgram.Rewards.Sender(basic: [], credit: []),
                                                                                                                   receiver: ReferralUser.ReferralProgram.Rewards.Receiver(basic: [], credit: []))))
        // TODO: verify program and rewards
        #expect(referralUser.stats == ReferralUser.Stats(claims: 10, conversions: 8, churns: 2))
    }
}
