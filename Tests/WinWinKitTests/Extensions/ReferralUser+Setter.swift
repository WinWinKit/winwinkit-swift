//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUser+Setter.swift
//
//  Created by Oleh Stasula on 30/01/2025.
//

@testable import WinWinKit

extension ReferralUser {
    
    func set(metadata: Metadata?) -> ReferralUser {
        .init(
            appUserId: self.appUserId,
            code: self.code,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt,
            metadata: metadata,
            program: self.program,
            rewards: self.rewards,
            stats: self.stats,
            claimCodeEligibility: self.claimCodeEligibility
        )
    }
}
