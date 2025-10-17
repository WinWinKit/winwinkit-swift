import AnyCodable
import Foundation
@testable import WinWinKit

enum MockUser {
    static let appUserId = "app-user-id-1"

    static func mock(
        appUserId: String = Self.appUserId,
        referralCode: String? = nil,
        referralCodeLink: String? = nil,
        isTrial: Bool? = nil,
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
                offerCode: [],
                googleplayPromoCode: [],
                revenuecatEntitlement: [],
                revenuecatOffering: []
            ),
            expired: .init(
                basic: [],
                credit: [],
                offerCode: [],
                googleplayPromoCode: [],
                revenuecatEntitlement: [],
                revenuecatOffering: []
            )
        ),
        referralProgram: ReferralProgram? = nil
    ) -> User {
        return User(
            appUserId: appUserId,
            referralCode: referralCode,
            referralCodeLink: referralCodeLink,
            isTrial: isTrial,
            isPremium: isPremium,
            firstSeenAt: firstSeenAt,
            lastSeenAt: lastSeenAt,
            metadata: metadata,
            claimCodeEligibility: claimCodeEligibility,
            stats: stats,
            rewards: rewards,
            referralProgram: referralProgram
        )
    }
}
