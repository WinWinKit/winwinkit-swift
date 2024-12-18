//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralUser.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

@testable import WinWinKit

enum MockReferralUser {
    static let referralUser1: ReferralUser = .init(appUserId: "app-user-id-1",
                                                   code: "XYZ123",
                                                   isPremium: nil,
                                                   firstSeenAt: nil,
                                                   lastSeenAt: nil,
                                                   program: nil,
                                                   rewards: ReferralUser.Rewards(basic: [],
                                                                                 credit: []))
}
