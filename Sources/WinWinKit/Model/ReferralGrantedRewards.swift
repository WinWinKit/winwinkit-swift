//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralGrantedRewards.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Foundation

public struct ReferralGrantedRewards: Codable {
    public let basic: [BasicReward]
    
    public struct BasicReward: Codable {
        public let key: String
        public let name: String
        public let description: String?
        public let metadata: Metadata?
        public let expiresAt: Date?
    }
}
