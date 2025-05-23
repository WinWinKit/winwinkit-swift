//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockNetworkReachability.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Foundation
@testable import WinWinKit

final class MockNetworkReachability: NetworkReachabilityType {
    var isReachable: Bool {
        get {
            self.isReachableGetterCallsCounter += 1
            return self._isReachable
        }
        set {
            self._isReachable = newValue
        }
    }

    private var _isReachable: Bool = false

    var delegate: NetworkReachabilityDelegate?

    func start() {
        self.startMethodCallsCounter += 1
    }

    var startMethodCallsCounter: Int = 0
    var isReachableGetterCallsCounter: Int = 0
}
