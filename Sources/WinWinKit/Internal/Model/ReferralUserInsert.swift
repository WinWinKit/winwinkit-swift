//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserInsert.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

struct ReferralUserInsert: Codable {
    let appUserId: String
    let isPremium: Bool?
    let firstSeenAt: Date?
    let lastSeenAt: Date?
    let metadata: Metadata?
}
