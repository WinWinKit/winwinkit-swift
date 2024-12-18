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

public struct ReferralUser: Codable, Hashable, Sendable {
    public let appUserId: String
    public let code: String?
    public let isPremium: Bool?
    public let firstSeenAt: Date?
    public let lastSeenAt: Date?
//    public let metadata: Any?
    public let program: ReferralProgram?
    public let rewards: Rewards
    
    public struct ReferralProgram: Codable, Hashable, Sendable {
        public let id: String
        public let name: String
        public let description: String?
        public let distributionPercentage: Int
        public let limit: Int
//        public let metadata: Any?
        public let rewards: Rewards
        
        public struct Rewards: Codable, Hashable, Sendable {
            public let basic: [BasicReward]
            public let credit: [CreditReward]
            
            public struct BasicReward: Codable, Hashable, Sendable {
                public let key: String
                public let description: String?
                public let side: Side
                //            public let metadata: [String: Any]?
                public let activationConfigurations: ActivationConfigurations
                public let deactivationConfigurations: DeactivationConfigurations
                
                public enum Side: String, Codable, Sendable {
                    case sender
                    case receiver
                }
                
                public struct ActivationConfigurations: Codable, Hashable, Sendable {
                    public let variant: Variant
                    public let amount: Int
                    
                    public enum Variant: String, Codable, Sendable {
                        case claim
                        case conversion
                    }
                }
                
                public struct DeactivationConfigurations: Codable, Hashable, Sendable {
                    public let variant: Variant
                    public let duration: Int?
                    public let period: Period?
                    
                    public enum Variant: String, Codable, Hashable, Sendable {
                        case never
                        case churn
                        case interval
                    }
                    
                    public enum Period: String, Codable, Hashable, Sendable {
                        case days
                        case months
                        case years
                    }
                }
            }
            
            public struct CreditReward: Codable, Hashable, Sendable {
                public let key: String
                public let description: String?
            }
        }
    }
    
    public struct Rewards: Codable, Hashable, Sendable {
        public let basic: [BasicReward]
        public let credit: [CreditReward]
        
        public struct BasicReward: Codable, Hashable, Sendable {
            public let key: String
            public let description: String?
    //        public let metadata: [String: Any]?
        }
        
        public struct CreditReward: Codable, Hashable, Sendable {
            public let key: String
            public let description: String?
    //        public let metadata: [String: Any]?
        }
    }
}
