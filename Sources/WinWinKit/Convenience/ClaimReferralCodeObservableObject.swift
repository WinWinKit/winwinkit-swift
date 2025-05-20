//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ClaimReferralCodeObservableObject.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

import Observation

@available(iOS 17.0, *)
@available(macOS 14.0, *)
@Observable
public final class ClaimReferralCodeObservableObject {
    
    public private(set) var isClaimingCode: Bool = false
    public private(set) var didClaimCodeSuccesfully: Bool? = nil
    public private(set) var rewardsGranted: UserRewardsGranted? = nil
    
    public func claim(code: String) {
        self.onClaimCode?(code)
    }
    
    // MARK: - Internal
    
    internal init() {
    }
    
    internal var onClaimCode: ((String) -> Void)?
    
    internal func set(isClaimingCode: Bool) {
        self.isClaimingCode = isClaimingCode
    }
    
    internal func set(didClaimCodeSuccesfully: Bool) {
        self.didClaimCodeSuccesfully = didClaimCodeSuccesfully
    }
    
    internal func set(rewardsGranted: UserRewardsGranted) {
        self.rewardsGranted = rewardsGranted
    }
}
