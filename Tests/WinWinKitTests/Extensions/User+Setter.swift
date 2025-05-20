//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  User+Setter.swift
//
//  Created by Oleh Stasula on 30/01/2025.
//

import AnyCodable
@testable import WinWinKit

extension User {
    func set(metadata: AnyCodable?) -> User {
        .init(
            appUserId: self.appUserId,
            code: self.code,
            previewLink: self.previewLink,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt,
            metadata: metadata,
            claimCodeEligibility: self.claimCodeEligibility,
            stats: self.stats,
            rewards: self.rewards,
            program: self.program
        )
    }
}
