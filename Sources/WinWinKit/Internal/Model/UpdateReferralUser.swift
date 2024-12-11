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

struct UpdateReferralUser: Codable {
    let appUserId: String
    let isPremium: Bool?
    let userSince: Date?
    let lastSeenAt: Date?
//    let metadata: Any?
}

extension UpdateReferralUser {
    
    func set(isPremium: Bool) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: isPremium,
            userSince: self.userSince,
            lastSeenAt: self.lastSeenAt
        )
    }
    
    func set(userSince: Date) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            userSince: userSince,
            lastSeenAt: self.lastSeenAt
        )
    }
    
    func set(lastSeenAt: Date) -> Self {
        UpdateReferralUser(
            appUserId: self.appUserId,
            isPremium: self.isPremium,
            userSince: self.userSince,
            lastSeenAt: lastSeenAt
        )
    }
}
