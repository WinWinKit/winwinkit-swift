//
// UserResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

internal struct UserResponse: Codable, Hashable {

    /** The user */
    public private(set) var user: User

    public init(user: User) {
        self.user = user
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case user
    }

    // Encodable protocol methods

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
    }
}

