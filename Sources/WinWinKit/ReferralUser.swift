//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUser.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

import Foundation

public struct ReferralUser: Codable {
    public typealias ID = String
    public let id: ID
    public let code: String?
    public let isPremium: Bool
    public let userSince: Date?
    public let lastSeenAt: Date?
//    public let metadata: Any?
    public let program: ReferralProgram?
    public let rewards: [Reward]
    
    public struct ReferralProgram: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let distributionPercentage: Int
        public let limit: Int
//        public let metadata: Any?
        public let rewards: [Reward]
        
        public struct Reward: Codable {
            public let key: String
            public let description: String?
            public let side: Side
//            public let metadata: [String: Any]?
            public let activationConfigurations: ActivationConfigurations
            public let deactivationConfigurations: DeactivationConfigurations
            
            public enum Side: String, Codable {
                case sender
                case receiver
            }
            
            public struct ActivationConfigurations: Codable {
                public let type: `Type`
                public let amount: Int
                
                public enum `Type`: String, Codable {
                    case claim
                    case conversion
                }
            }
            
            public struct DeactivationConfigurations: Codable {
                public let type: `Type`
                public let duration: Int?
                public let period: Period?
                
                public enum `Type`: String, Codable {
                    case never
                    case churn
                    case interval
                }
                
                public enum Period: String, Codable {
                    case days
                    case months
                    case years
                }
            }
        }
    }
    
    public struct Reward: Codable {
        public let key: String
        public let description: String?
//        public let metadata: [String: Any]?
    }
}
