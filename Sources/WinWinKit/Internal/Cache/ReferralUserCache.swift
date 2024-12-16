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
    subscript(referralUser key: String) -> ReferralUser? { get set }
    subscript(updateReferralUser key: String) -> UpdateReferralUser? { get set }
}

final class ReferralUserCache: ReferralUserCacheType {
    let keyValueCache: KeyValueCacheType
    
    init(keyValueCache: KeyValueCacheType) {
        self.keyValueCache = keyValueCache
    }
    
    // MARK: - ReferralUserCacheType
    
    subscript(referralUser key: String) -> ReferralUser? {
        get {
            do {
                return try self.keyValueCache[key].map { try ReferralUser(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize ReferralUser.")
                return nil
            }
        }
        set {
            do {
                self.keyValueCache[key] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize ReferralUser.")
            }
        }
    }
    
    subscript(updateReferralUser key: String) -> UpdateReferralUser? {
        get {
            do {
                return try self.keyValueCache[key].map { try UpdateReferralUser(jsonData: $0) }
            }
            catch {
                Logger.error("Unable to deserialize update ReferralUser.")
                return nil
            }
        }
        set {
            do {
                self.keyValueCache[key] = try newValue?.jsonData()
            }
            catch {
                Logger.error("Unable to serialize update ReferralUser.")
            }
        }
    }
}
