//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserObservableObject.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import Observation

@available(iOS 17.0, *)
@available(macOS 14.0, *)
@Observable
public final class UserObservableObject {
    
    public private(set) var user: User?
    public private(set) var isRefreshing: Bool = false
    
    // MARK: - Internal
    
    internal init() {
    }
    
    internal func set(user: User?) {
        self.user = user
    }
    
    internal func set(isRefreshing: Bool) {
        self.isRefreshing = isRefreshing
    }
}
