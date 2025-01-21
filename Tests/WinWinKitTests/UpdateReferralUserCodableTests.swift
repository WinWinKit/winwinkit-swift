//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UpdateReferralUserCodableTests.swift
//
//  Created by Oleh Stasula on 19/12/2024.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct UpdateReferralUserCodableTests {
    
    @Test func encodingEmpty() throws {
        let referralUser = ReferralUserUpdate(appUserId: "app-user-id-1",
                                              isPremium: nil,
                                              firstSeenAt: nil,
                                              lastSeenAt: nil,
                                              metadata: nil)
        let jsonData = try referralUser.jsonData()
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let expectedJsonString = "{\"app_user_id\":\"app-user-id-1\"}"
        #expect(jsonString == expectedJsonString)
    }
    
    @Test func encodingMetadataObject() throws {
        let referralUser = ReferralUserUpdate(appUserId: "app-user-id-1",
                                              isPremium: nil,
                                              firstSeenAt: nil,
                                              lastSeenAt: nil,
                                              metadata: ["key-1": "value-1"])
        let jsonData = try referralUser.jsonData()
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let expectedJsonString = "{\"app_user_id\":\"app-user-id-1\",\"metadata\":{\"key-1\":\"value-1\"}}"
        #expect(jsonString == expectedJsonString)
    }
    
    @Test func encodingMetadataEmptyObject() throws {
        let referralUser = ReferralUserUpdate(appUserId: "app-user-id-1",
                                              isPremium: nil,
                                              firstSeenAt: nil,
                                              lastSeenAt: nil,
                                              metadata: [:])
        let jsonData = try referralUser.jsonData()
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let expectedJsonString = "{\"app_user_id\":\"app-user-id-1\",\"metadata\":{}}"
        #expect(jsonString == expectedJsonString)
    }
    
    @Test func encodingMetadataArray() throws {
        let referralUser = ReferralUserUpdate(appUserId: "app-user-id-1",
                                              isPremium: nil,
                                              firstSeenAt: nil,
                                              lastSeenAt: nil,
                                              metadata: ["value-1", "value-2"])
        let jsonData = try referralUser.jsonData()
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let expectedJsonString = "{\"app_user_id\":\"app-user-id-1\",\"metadata\":[\"value-1\",\"value-2\"]}"
        #expect(jsonString == expectedJsonString)
    }
    
    @Test func encodingMetadataEmptyArray() throws {
        let referralUser = ReferralUserUpdate(appUserId: "app-user-id-1",
                                              isPremium: nil,
                                              firstSeenAt: nil,
                                              lastSeenAt: nil,
                                              metadata: [])
        let jsonData = try referralUser.jsonData()
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let expectedJsonString = "{\"app_user_id\":\"app-user-id-1\",\"metadata\":[]}"
        #expect(jsonString == expectedJsonString)
    }
}
