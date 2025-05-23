//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockKeyValueCache.swift
//
//  Created by Oleh Stasula on 23/05/2025.
//

import Foundation
@testable import WinWinKit

final class MockKeyValueCache: KeyValueCacheType {
    var data: [String: Data] = [:]

    subscript(key: String) -> Data? {
        get {
            return self.data[key]
        }
        set {
            self.data[key] = newValue
        }
    }
}
