//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralsObservableObject.swift
//
//  Created by Oleh Stasula on 22/05/2025.
//

import AnyCodable
import Foundation
import Observation

@available(iOS 17.0, *)
@available(macOS 14.0, *)
@Observable
public final class ReferralsObservableObject {
    // User
    public internal(set) var user: User?

    // User State
    public enum UserState {
        case none
        case loading
        case available
        case failure(Error)

        public var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        public var isAvailable: Bool {
            switch self {
            case .available:
                return true
            default:
                return false
            }
        }

        public var isFailure: Bool {
            switch self {
            case .failure:
                return true
            default:
                return false
            }
        }

        public var errorObjects: [ErrorObject]? {
            switch self {
            case .failure(let error):
                return (error as? ReferralsError)?.errorObjects
            default:
                return nil
            }
        }
    }

    public internal(set) var userState: UserState = .none

    // Claim Code
    public enum ClaimCodeState {
        case none
        case loading
        case success(UserRewardsGranted)
        case failure(Error)

        public var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        public var isSuccess: Bool {
            switch self {
            case .success:
                return true
            default:
                return false
            }
        }

        public var isFailure: Bool {
            switch self {
            case .failure:
                return true
            default:
                return false
            }
        }

        public var errorObjects: [ErrorObject]? {
            switch self {
            case .failure(let error):
                return (error as? ReferralsError)?.errorObjects
            default:
                return nil
            }
        }
    }

    public internal(set) var claimCodeState: ClaimCodeState = .none

    public func claimCode(code: String) {
        self.onClaimCode?(code)
    }

    // Grant Reward
    public enum GrantRewardState {
        case none
        case loading
        case success(UserRewardsGranted)
        case failure(Error)

        public var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        public var isSuccess: Bool {
            switch self {
            case .success:
                return true
            default:
                return false
            }
        }

        public var isFailure: Bool {
            switch self {
            case .failure:
                return true
            default:
                return false
            }
        }

        public var errorObjects: [ErrorObject]? {
            switch self {
            case .failure(let error):
                return (error as? ReferralsError)?.errorObjects
            default:
                return nil
            }
        }
    }

    public internal(set) var grantRewardState: GrantRewardState = .none

    ///
    /// Grant a reward to the current user.
    ///
    /// - Important: This endpoint is only accessible when ``Referrals`` was configured
    /// with a **secret API key**. Calls made with a public key will be rejected by the server.
    ///
    public func grantReward(key: String, operationId: String? = nil) {
        self.onGrantReward?(key, operationId)
    }

    // Withdraw Credits
    public enum WithdrawCreditsState {
        case none
        case loading
        case success(UserWithdrawCreditsResult)
        case failure(Error)

        public var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        public var isSuccess: Bool {
            switch self {
            case .success:
                return true
            default:
                return false
            }
        }

        public var isFailure: Bool {
            switch self {
            case .failure:
                return true
            default:
                return false
            }
        }

        public var errorObjects: [ErrorObject]? {
            switch self {
            case .failure(let error):
                return (error as? ReferralsError)?.errorObjects
            default:
                return nil
            }
        }
    }

    public internal(set) var withdrawCreditsState: WithdrawCreditsState = .none

    public func withdrawCredits(key: String, amount: Int) {
        self.onWithdrawCredits?(key, amount)
    }

    // User properties
    public func set(appUserId: String) {
        self.onSetAppUserId?(appUserId)
    }

    public func set(isPremium: Bool) {
        self.onSetIsPremium?(isPremium)
    }

    public func set(isTrial: Bool) {
        self.onSetIsTrial?(isTrial)
    }

    public func set(firstSeenAt: Date) {
        self.onSetFirstSeenAt?(firstSeenAt)
    }

    public func set(metadata: AnyCodable) {
        self.onSetMetadata?(metadata)
    }

    public func set(stripeCustomerId: String?) {
        self.onSetStripeCustomerId?(stripeCustomerId)
    }

    // Lifecycle
    public func refresh() {
        self.onRefresh?()
    }

    public func syncTransactions() {
        self.onSyncTransactions?()
    }

    public func reset() {
        self.onReset?()
    }

    // MARK: - Internal

    init() {}

    var onClaimCode: ((String) -> Void)?
    var onGrantReward: ((String, String?) -> Void)?
    var onWithdrawCredits: ((String, Int) -> Void)?
    var onSetAppUserId: ((String) -> Void)?
    var onSetIsPremium: ((Bool) -> Void)?
    var onSetIsTrial: ((Bool) -> Void)?
    var onSetFirstSeenAt: ((Date) -> Void)?
    var onSetMetadata: ((AnyCodable) -> Void)?
    var onSetStripeCustomerId: ((String?) -> Void)?
    var onRefresh: (() -> Void)?
    var onSyncTransactions: (() -> Void)?
    var onReset: (() -> Void)?
}
