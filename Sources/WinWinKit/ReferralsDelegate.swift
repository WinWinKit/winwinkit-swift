//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralsDelegate.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

public protocol ReferralsDelegate: AnyObject {
    func referrals(_ referrals: Referrals, receivedUpdated user: User?)
    func referrals(_ referrals: Referrals, receivedError error: Error)
}
