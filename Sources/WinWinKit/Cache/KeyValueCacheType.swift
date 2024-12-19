//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  KeyValueCacheType.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

public protocol KeyValueCacheType: AnyObject {
    subscript(_ key: String) -> Data? { get set }
}

extension UserDefaults: KeyValueCacheType {
    
    public subscript(_ key: String) -> Data? {
        get {
            self.data(forKey: key)
        }
        set {
            self.set(newValue, forKey: key)
        }
    }
}
