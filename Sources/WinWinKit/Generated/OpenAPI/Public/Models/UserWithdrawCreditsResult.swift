//
// UserWithdrawCreditsResult.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct UserWithdrawCreditsResult: Codable, Hashable {

    /** The amount of credits available at the start */
    public private(set) var creditsAvailableAtStart: Int
    /** The amount of credits available at the end */
    public private(set) var creditsAvailableAtEnd: Int
    /** The amount of credits requested to withdraw */
    public private(set) var creditsRequestedToWithdraw: Int
    /** The amount of credits withdrawn */
    public private(set) var creditsWithdrawn: Int

    public init(creditsAvailableAtStart: Int, creditsAvailableAtEnd: Int, creditsRequestedToWithdraw: Int, creditsWithdrawn: Int) {
        self.creditsAvailableAtStart = creditsAvailableAtStart
        self.creditsAvailableAtEnd = creditsAvailableAtEnd
        self.creditsRequestedToWithdraw = creditsRequestedToWithdraw
        self.creditsWithdrawn = creditsWithdrawn
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case creditsAvailableAtStart = "credits_available_at_start"
        case creditsAvailableAtEnd = "credits_available_at_end"
        case creditsRequestedToWithdraw = "credits_requested_to_withdraw"
        case creditsWithdrawn = "credits_withdrawn"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creditsAvailableAtStart, forKey: .creditsAvailableAtStart)
        try container.encode(creditsAvailableAtEnd, forKey: .creditsAvailableAtEnd)
        try container.encode(creditsRequestedToWithdraw, forKey: .creditsRequestedToWithdraw)
        try container.encode(creditsWithdrawn, forKey: .creditsWithdrawn)
    }
}

