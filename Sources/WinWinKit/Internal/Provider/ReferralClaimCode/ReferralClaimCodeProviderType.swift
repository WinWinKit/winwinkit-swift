//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralClaimCodeProviderType.swift
//
//  Created by Oleh Stasula on 21/01/2025.
//

struct ReferralClaimCodeResult {
    let referralUser: ReferralUser
    let grantedRewards: ReferralGrantedRewards
}

protocol ReferralClaimCodeProviderType {
    func claim(code: String, appUserId: String, projectKey: String) async throws -> ReferralClaimCodeResult
}
