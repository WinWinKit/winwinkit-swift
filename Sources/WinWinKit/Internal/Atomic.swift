//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  Atomic.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation
import os

@propertyWrapper
struct Atomic<Value> {

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            self.lock.lock(); defer { self.lock.unlock() }
            return self.value
        }
        _modify {
            self.lock.lock(); defer { self.lock.unlock() }
            yield &self.value
        }
    }
    
    private var value: Value
    
    private let lock: UnfairLock = .init()
}

private final class UnfairLock {

    init() {
        self.pointer = .allocate(capacity: 1)
        self.pointer.initialize(to: os_unfair_lock())
    }

    deinit {
        self.pointer.deinitialize(count: 1)
        self.pointer.deallocate()
    }

    func lock() {
        os_unfair_lock_lock(self.pointer)
    }

    func unlock() {
        os_unfair_lock_unlock(self.pointer)
    }

    @discardableResult
    @inlinable
    func execute<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }
    
    // MARK: Private

    private let pointer: os_unfair_lock_t
}
