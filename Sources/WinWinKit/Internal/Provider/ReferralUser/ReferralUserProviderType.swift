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
    func fetch(appUserId: String, projectKey: String) async throws -> ReferralUser?
    func create(referralUser: InsertReferralUser, projectKey: String) async throws -> ReferralUser
    func update(referralUser: UpdateReferralUser, projectKey: String) async throws -> ReferralUser
}
