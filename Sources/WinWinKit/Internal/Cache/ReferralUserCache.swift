//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserCache.swift
//
//  Created by Oleh Stasula on 14/12/2024.
//

protocol ReferralUserCacheType: AnyObject {
    var referralUser: ReferralUser? { get set }
    var updateReferralUser: UpdateReferralUser? { get set }
}

final class ReferralUserCache: ReferralUserCacheType {
    
    let keyValueCache: KeyValueCacheType
    
    init(keyValueCache: KeyValueCacheType) {
        self.keyValueCache = keyValueCache
    }
    
    // MARK: - ReferralUserCacheType
    
    var referralUser: ReferralUser? {
        get {
            do {
                return try self.keyValueCache[Keys.referralUser].map { try ReferralUser(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize ReferralUser.")
                return nil
            }
        }
        set {
            do {
                self.keyValueCache[Keys.referralUser] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize ReferralUser.")
            }
        }
    }
    
    var updateReferralUser: UpdateReferralUser? {
        get {
            do {
                return try self.keyValueCache[Keys.updateReferralUser].map { try UpdateReferralUser(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize update ReferralUser.")
                return nil
            }
        }
        set {
            do {
                self.keyValueCache[Keys.updateReferralUser] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize update ReferralUser.")
            }
        }
    }
    
    // MARK: - Private
    
    private enum Keys {
        static let referralUser = "com.winwinkit.cache.referralUser"
        static let updateReferralUser = "com.winwinkit.cache.updateReferralUser"
    }
}
