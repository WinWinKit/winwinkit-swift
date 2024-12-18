//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserServiceDelegate.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

protocol ReferralUserServiceDelegate: AnyObject {
    func referralUserService(_ service: ReferralUserService, receivedUpdated referralUser: ReferralUser)
    func referralUserService(_ service: ReferralUserService, isRefreshingChanged isRefreshing: Bool)
}
