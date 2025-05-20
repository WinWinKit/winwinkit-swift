//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockUserServiceDelegate.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

@testable import WinWinKit

final class MockUserServiceDelegate: UserServiceDelegate {
    var canPerformNextRefresh: Bool = true
    var user: User? = nil
    var isRefreshing: Bool? = nil

    var canPerformNextRequestMethodCallsCounter: Int = 0
    var receivedUpdatedUserMethodCallsCounter: Int = 0
    var receivedErrorMethodCallsCounter: Int = 0
    var isRefreshingChangedMethodCallsCounter: Int = 0

    var isRefreshingChangedCallback: ((Bool) -> Void)?

    func userServiceCanPerformNextRefresh(_: UserService) -> Bool {
        self.canPerformNextRequestMethodCallsCounter += 1
        return self.canPerformNextRefresh
    }

    func userService(_: UserService, receivedUpdated user: User) {
        self.user = user
        self.receivedUpdatedUserMethodCallsCounter += 1
    }

    func userService(_: UserService, receivedError _: any Error) {
        self.receivedErrorMethodCallsCounter += 1
    }

    func userService(_: UserService, isRefreshingChanged isRefreshing: Bool) {
        self.isRefreshing = isRefreshing
        self.isRefreshingChangedMethodCallsCounter += 1
        self.isRefreshingChangedCallback?(isRefreshing)
    }
}
