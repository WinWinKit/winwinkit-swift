//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteRequest.swift
//
//  Created by Oleh Stasula on 18/12/2024.
//

import Foundation

protocol RemoteRequest {
    func urlRequest() throws -> URLRequest
}
