//
// UserRewardsActive.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct UserRewardsActive: Codable, Hashable {

    /** The referral user basic rewards */
    public private(set) var basic: [UserBasicRewardActive]
    /** The referral user credit rewards */
    public private(set) var credit: [UserCreditRewardActive]
    /** The referral user offer code rewards */
    public private(set) var offerCode: [UserOfferCodeRewardActive]

    public init(basic: [UserBasicRewardActive], credit: [UserCreditRewardActive], offerCode: [UserOfferCodeRewardActive]) {
        self.basic = basic
        self.credit = credit
        self.offerCode = offerCode
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case basic
        case credit
        case offerCode = "offer_code"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(basic, forKey: .basic)
        try container.encode(credit, forKey: .credit)
        try container.encode(offerCode, forKey: .offerCode)
    }
}

