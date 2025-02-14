//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralUserRequest.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

enum RemoteReferralUserRequestError: Error {
    case unableToCreateURL
}

struct RemoteReferralUserRequest: RemoteRequest {
    
    enum Request {
        case get(appUserId: String)
        case post(user: ReferralUserUpdate)
    }
    
    let baseEndpointURL: URL
    let projectKey: String
    let request: Request
    
    // MARK: - RemoteRequest
    
    func urlRequest() throws -> URLRequest {
        guard
            let url = URL(string: self.request.path, relativeTo: self.baseEndpointURL)
        else {
            throw RemoteReferralUserRequestError.unableToCreateURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.request.httpMethod
        urlRequest.httpBody = try self.request.httpBody()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(self.projectKey, forHTTPHeaderField: "X-API-Key")
        return urlRequest
    }
}

extension RemoteReferralUserRequest.Request {
    
    fileprivate var httpMethod: String {
        switch self {
        case .get: "GET"
        case .post: "POST"
        }
    }
    
    fileprivate func httpBody() throws -> Data? {
        switch self {
        case .get: nil
        case .post(let referralUser): try referralUser.jsonData()
        }
    }
    
    fileprivate var path: String {
        switch self {
        case .get(let appUserId): "referral/users/\(appUserId)"
        case .post: "referral/users"
        }
    }
}
