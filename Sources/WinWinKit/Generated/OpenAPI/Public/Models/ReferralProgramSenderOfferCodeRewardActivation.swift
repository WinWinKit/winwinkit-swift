//
// ReferralProgramSenderOfferCodeRewardActivation.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct ReferralProgramSenderOfferCodeRewardActivation: Codable, Hashable {

    public enum Variant: String, Codable, CaseIterable {
        case claim = "claim"
        case conversion = "conversion"
    }
    /** The variant of the activation configuration */
    public private(set) var variant: Variant
    /** The amount of the activation configuration */
    public private(set) var amount: Int
    /** The limit of the activation configuration */
    public private(set) var limit: Int

    public init(variant: Variant, amount: Int, limit: Int) {
        self.variant = variant
        self.amount = amount
        self.limit = limit
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case variant
        case amount
        case limit
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(variant, forKey: .variant)
        try container.encode(amount, forKey: .amount)
        try container.encode(limit, forKey: .limit)
    }
}

