//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockModel.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation
@testable import WinWinKit

enum MockReferralProgram {
    
    enum Full {
        
        static let object: ReferralUser.ReferralProgram = .init(
            id: "j34me52cznsa2wt6xwbgfimp",
            name: "Program #1",
            description: nil,
            distributionPercentage: 0,
            limit: 0,
            metadata: nil,
            rewards: ReferralUser.ReferralProgram.Rewards(
                sender: ReferralUser.ReferralProgram.Rewards.Sender(
                    basic: [],
                    credit: []
                ),
                receiver: ReferralUser.ReferralProgram.Rewards.Receiver(
                    basic: [],
                    credit: []
                )
            )
        )
        
        static let jsonString: String = """
            {
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
            }
            """
        
        static let data: Data = Self.jsonString.data(using: .utf8)!
    }
}

enum MockReferralUser {
    
    enum Full {
        
        static let object: ReferralUser = .init(
            appUserId: "app-user-id-1",
            code: "XYZ123",
            isPremium: true,
            firstSeenAt: Date(timeIntervalSince1970: 1607253359),
            lastSeenAt: Date(timeIntervalSince1970: 1733483759),
            metadata: ["1": 123],
            program: MockReferralProgram.Full.object,
            rewards: ReferralUser.Rewards(
                active: ReferralUser.Rewards.Active(
                    basic: [],
                    credit: []
                )
            ),
            stats: ReferralUser.Stats(
                claims: 10,
                conversions: 8,
                churns: 2
            ),
            claimCodeEligibility: ReferralUser.ClaimCodeEligibility(
                eligible: true
            )
        )
        
        static let data: Data = """
            {
                "app_user_id": "app-user-id-1",
                "code": "XYZ123",
                "is_premium": true,
                "first_seen_at": "2020-12-06T11:15:59.000000+00:00",
                "last_seen_at": "2024-12-06T11:15:59.000000+00:00",
                "metadata": {
                    "1": 123
                },
                "program": \(MockReferralProgram.Full.jsonString),
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
                },
                "claim_code_eligibility": {
                    "eligible": true
                }
            }
            """
            .data(using: .utf8)!
    }
    
    enum Empty {
        
        static let object: ReferralUser = .init(
            appUserId: "app-user-id-2",
            code: nil,
            isPremium: nil,
            firstSeenAt: nil,
            lastSeenAt: nil,
            metadata: nil,
            program: nil,
            rewards: ReferralUser.Rewards(
                active: ReferralUser.Rewards.Active(
                    basic: [],
                    credit: []
                )
            ),
            stats: ReferralUser.Stats(
                claims: 0,
                conversions: 0,
                churns: 0
            ),
            claimCodeEligibility: ReferralUser.ClaimCodeEligibility(
                eligible: false
            )
        )
    }
}

enum MockInsertReferralUser {
    
    enum Full {
        
        static let object: InsertReferralUser = .init(
            appUserId: MockReferralUser.Full.object.appUserId,
            isPremium: MockReferralUser.Full.object.isPremium,
            firstSeenAt: MockReferralUser.Full.object.firstSeenAt,
            lastSeenAt: MockReferralUser.Full.object.lastSeenAt,
            metadata: MockReferralUser.Full.object.metadata
        )
    }
}
