//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockReferralsDelegate.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

@testable import WinWinKit

final class MockReferralsDelegate: ReferralsDelegate {
    var receivedUpdatedUserCallsCounter: Int = 0
    var receivedErrorCallsCounter: Int = 0

    var onReceivedUpdatedUser: ((User?) -> Void)?
    var onReceivedError: ((any Error) -> Void)?

    func referrals(_ referrals: Referrals, receivedUpdated user: User?) {
        self.receivedUpdatedUserCallsCounter += 1
        self.onReceivedUpdatedUser?(user)
    }

    func referrals(_ referrals: Referrals, receivedError error: any Error) {
        self.receivedErrorCallsCounter += 1
        self.onReceivedError?(error)
    }
}
