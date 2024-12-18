//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UpdateReferralUser.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

struct UpdateReferralUser: Codable, Hashable {
    let appUserId: String
    let isPremium: Bool?
    let firstSeenAt: Date?
    let lastSeenAt: Date?
//    let metadata: Any?
}

extension UpdateReferralUser {
    
    func set(isPremium: Bool) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt
        )
    }
    
    func set(firstSeenAt: Date) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: firstSeenAt,
            lastSeenAt: self.lastSeenAt
        )
    }
    
    func set(lastSeenAt: Date) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: lastSeenAt
        )
    }
}

extension UpdateReferralUser {
    
    var asInsertReferralUser: InsertReferralUser {
        InsertReferralUser(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            firstSeenAt: self.firstSeenAt,
            lastSeenAt: self.lastSeenAt
        )
    }
}
