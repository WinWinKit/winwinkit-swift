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
    }

    public internal(set) var claimCodeState: ClaimCodeState = .none

    public func claimCode(code: String) {
        self.onClaimCode?(code)
    }

    // Offer Codes
    public enum OfferCodeState {
        case loading
        case success(AppStoreOfferCode, AppStoreSubscription)
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
    }

    public internal(set) var offerCodesState: [String: OfferCodeState] = [:]

    public func fetchOfferCode(offerCodeId: String) {
        self.onFetchOfferCode?(offerCodeId)
    }

    // MARK: - Internal

    init() {}

    var onClaimCode: ((String) -> Void)?
    var onFetchOfferCode: ((String) -> Void)?
}
