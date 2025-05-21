//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserCache.swift
//
//  Created by Oleh Stasula on 14/12/2024.
//

protocol UserCacheType {
    var user: User? { get nonmutating set }
    var userUpdate: UserUpdate? { get nonmutating set }
}

extension UserCacheType {
    func reset() {
        self.user = nil
        self.userUpdate = nil
    }
}

struct UserCache: UserCacheType {
    let keyValueCache: KeyValueCacheType

    // MARK: - UserCacheType

    var user: User? {
        get {
            do {
                return try self.keyValueCache[Keys.user].map { try User(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize User.")
                return nil
            }
        }
        nonmutating set {
            do {
                self.keyValueCache[Keys.user] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize User.")
            }
        }
    }

    var userUpdate: UserUpdate? {
        get {
            do {
                return try self.keyValueCache[Keys.userUpdate].map { try UserUpdate(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize update UserUpdate.")
                return nil
            }
        }
        nonmutating set {
            do {
                self.keyValueCache[Keys.userUpdate] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize update UserUpdate.")
            }
        }
    }

    // MARK: - Private

    private enum Keys {
        static let user = "com.winwinkit.cache.user"
        static let userUpdate = "com.winwinkit.cache.userUpdate"
    }
}
