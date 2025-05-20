//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserUpdate.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import AnyCodable
import Foundation

struct UserUpdate: Codable, Hashable {
    let appUserId: String
    let isPremium: Bool?
    let firstSeenAt: Date?
    let lastSeenAt: Date?
    let metadata: AnyCodable?
}

extension UserUpdate {
    
    func set(isPremium: Bool) -> Self {
        UserUpdate(
            appUserId: self.appUserId,
            isPremium: isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt,
            metadata: self.metadata
        )
    }
    
    func set(firstSeenAt: Date) -> Self {
        UserUpdate(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: firstSeenAt,
            lastSeenAt: self.lastSeenAt,
            metadata: self.metadata
        )
    }
    
    func set(lastSeenAt: Date) -> Self {
        UserUpdate(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: lastSeenAt,
            metadata: self.metadata
        )
    }
    
    func set(metadata: AnyCodable) -> Self {
        UserUpdate(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt,
            metadata: metadata
        )
    }
}
