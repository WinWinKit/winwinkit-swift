import AnyCodable
import Foundation
@testable import WinWinKit

enum MockUser {
    static let appUserId = "app-user-id-1"

    static func mock(
        appUserId: String = Self.appUserId,
        code: String? = nil,
        previewLink: String? = nil,
        isPremium: Bool? = nil,
        firstSeenAt: Date? = nil,
        lastSeenAt: Date? = nil,
        metadata: AnyCodable? = nil,
        claimCodeEligibility: UserClaimCodeEligibility = .init(
            eligible: false,
            eligibleUntil: nil
        ),
        stats: UserStats = .init(
            claims: 0,
            conversions: 0,
            churns: 0
        ),
        rewards: UserRewards = .init(
            active: .init(
                basic: [],
                credit: [],
                offerCode: []
            ),
            expired: .init(
                basic: [],
                credit: [],
                offerCode: []
            )
        ),
        program: Program? = nil
    ) -> User {
        return User(
            appUserId: appUserId,
            code: code,
            previewLink: previewLink,
            isPremium: isPremium,
            firstSeenAt: firstSeenAt,
            lastSeenAt: lastSeenAt,
            metadata: metadata,
            claimCodeEligibility: claimCodeEligibility,
            stats: stats,
            rewards: rewards,
            program: program
        )
    }
}
