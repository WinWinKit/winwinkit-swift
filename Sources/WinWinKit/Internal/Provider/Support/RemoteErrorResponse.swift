//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteErrorResponse.swift
//
//  Created by Oleh Stasula on 29/01/2025.
//

struct RemoteErrorsResponse: Codable {
    let errors: [Error]
    
    struct Error: Codable {
        let code: String
        let status: Int
        let title: String
        let source: String?
    }
}
