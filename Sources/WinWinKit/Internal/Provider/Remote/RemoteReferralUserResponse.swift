//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserResponse.swift
//
//  Created by Oleh Stasula on 17/12/2024.
//

struct RemoteReferralUserResponse: Codable {
    let data: Data?
    
    struct Data: Codable {
        let referralUser: ReferralUser?
    }
}
