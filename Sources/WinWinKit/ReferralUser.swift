//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUser.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

public struct ReferralUser: Codable {
    public typealias ID = String
    public let id: ID
    public let code: String?
}
