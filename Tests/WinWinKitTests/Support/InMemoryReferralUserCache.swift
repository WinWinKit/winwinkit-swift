//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  InMemoryReferralUserCache.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation
import WinWinKit

struct InMemoryReferralUserCache: KeyValueCacheType {
    
    subscript(key: String) -> Data? {
        get {
            self.cache[key]
        }
        set(newValue) {
            self.cache[key] = newValue
        }
    }
    
    private var cache: [String: Data] = [:]
}
