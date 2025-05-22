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

    // Claim Referral Code
    public enum ClaimReferralCodeState {
        case none
        case loading
        case success(UserRewardsGranted)
        case failure(Error)
    }

    public internal(set) var claimReferralCodeState: ClaimReferralCodeState = .none

    public func claimReferralCode(code: String) {
        self.onClaimReferralCode?(code)
    }

    // Offer Codes
    public enum OfferCodeState {
        case loading
        case success(AppStoreOfferCode, AppStoreSubscription)
        case failure(Error)
    }

    public internal(set) var offerCodesState: [String: OfferCodeState] = [:]

    public func fetchOfferCode(offerCodeId: String) {
        self.onFetchOfferCode?(offerCodeId)
    }

    // MARK: - Internal

    init() {}

    var onClaimReferralCode: ((String) -> Void)?
    var onFetchOfferCode: ((String) -> Void)?
}
