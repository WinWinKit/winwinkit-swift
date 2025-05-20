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

enum MockProgram {
    enum Full {
        static let object: Program = .init(
            id: "j34me52cznsa2wt6xwbgfimp",
            name: "Program #1",
            description: nil,
            metadata: nil,
            distributionPercentage: 0,
            limit: 0,
            rewards: ProgramRewards(
                sender: ProgramSenderRewards(
                    basic: [
                        ProgramSenderBasicReward(
                            reward: BasicReward(
                                key: "basic-reward-1",
                                name: "Basic Reward 1",
                                description: nil,
                                metadata: nil,
                                createdAt: Date(timeIntervalSince1970: 1_733_483_759),
                                updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
                            ),
                            activation: ProgramSenderBasicRewardActivation(
                                variant: .claim,
                                value: 2
                            ),
                            deactivation: .typeProgramSenderBasicRewardIntervalDeactivation(
                                ProgramSenderBasicRewardIntervalDeactivation(
                                    variant: .interval,
                                    duration: 2,
                                    period: .months
                                )
                            )
                        ),
                    ],
                    credit: [],
                    offerCode: []
                ),
                receiver: ProgramReceiverRewards(
                    basic: [],
                    credit: [],
                    offerCode: []
                )
            ),
            createdAt: Date(timeIntervalSince1970: 1_733_483_759),
            updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
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
                    "basic": [
                        {
                            "key": "basic-reward-1",
                            "name": "Basic Reward 1",
                            "description": null,
                            "metadata": null,
                            "activation_configurations": {
                                "variant": "claim",
                                "amount": 2
                            },
                            "deactivation_configurations": {
                                "variant": "interval",
                                "duration": 2,
                                "period": "months"
                            }
                        }
                    ],
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

enum MockUser {
    enum Full {
        static let object: User = .init(
            appUserId: "app-user-id-1",
            code: "XYZ123",
            previewLink: "https://usage.wwk.link/XYZ123",
            isPremium: true,
            firstSeenAt: Date(timeIntervalSince1970: 1_607_253_359),
            lastSeenAt: Date(timeIntervalSince1970: 1_733_483_759),
            metadata: ["1": 123],
            claimCodeEligibility: UserClaimCodeEligibility(
                eligible: true,
                eligibleUntil: Date(timeIntervalSince1970: 1_733_483_759)
            ),
            stats: UserStats(
                claims: 10,
                conversions: 8,
                churns: 2
            ),
            rewards: UserRewards(
                active: UserRewardsActive(
                    basic: [
                        UserBasicRewardActive(
                            reward: BasicReward(
                                key: "basic-reward-1",
                                name: "Basic Reward 1",
                                description: nil,
                                metadata: nil,
                                createdAt: Date(timeIntervalSince1970: 1_733_483_759),
                                updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
                            ),
                            expiresAt: nil,
                            createdAt: Date(timeIntervalSince1970: 1_733_483_759),
                            updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
                        ),
                    ],
                    credit: [],
                    offerCode: []
                ),
                expired: UserRewardsExpired(
                    basic: [
                        UserBasicRewardExpired(
                            reward: BasicReward(
                                key: "basic-reward-11",
                                name: "Basic Reward 11",
                                description: nil,
                                metadata: nil,
                                createdAt: Date(timeIntervalSince1970: 1_733_483_759),
                                updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
                            ),
                            expiredAt: Date(timeIntervalSince1970: 1_733_483_759),
                            createdAt: Date(timeIntervalSince1970: 1_733_483_759),
                            updatedAt: Date(timeIntervalSince1970: 1_733_483_759)
                        ),
                    ],
                    credit: [],
                    offerCode: []
                )
            ),
            program: MockProgram.Full.object
        )
    }

    enum Empty {
        static let object: User = .init(
            appUserId: "app-user-id-2",
            code: nil,
            previewLink: nil,
            isPremium: nil,
            firstSeenAt: nil,
            lastSeenAt: nil,
            metadata: nil,
            claimCodeEligibility: UserClaimCodeEligibility(
                eligible: false,
                eligibleUntil: nil
            ),
            stats: UserStats(
                claims: 0,
                conversions: 0,
                churns: 0
            ),
            rewards: UserRewards(
                active: UserRewardsActive(
                    basic: [],
                    credit: [],
                    offerCode: []
                ),
                expired: UserRewardsExpired(
                    basic: [],
                    credit: [],
                    offerCode: []
                )
            ),
            program: nil
        )
    }
}

enum MockUserUpdate {
    enum Full {
        static let object: UserUpdate = .init(
            appUserId: MockUser.Full.object.appUserId,
            isPremium: MockUser.Full.object.isPremium,
            firstSeenAt: MockUser.Full.object.firstSeenAt,
            lastSeenAt: MockUser.Full.object.lastSeenAt,
            metadata: MockUser.Full.object.metadata
        )
    }
}
