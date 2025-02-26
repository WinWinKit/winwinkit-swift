//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserProviderType.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

protocol ReferralUserProviderType {
    func fetch(appUserId: String, apiKey: String) async throws -> ReferralUser?
    func createOrUpdate(referralUser: ReferralUserUpdate, apiKey: String) async throws -> ReferralUser
}
