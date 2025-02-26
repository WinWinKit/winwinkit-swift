//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteReferralClaimCodeRequest.swift
//
//  Created by Oleh Stasula on 05/12/2024.
//

import Foundation

enum RemoteReferralClaimCodeRequestError: Error {
    case unableToCreateURL
}

struct RemoteReferralClaimCodeRequest: RemoteRequest {
    
    enum Request {
        case claim(code: String, appUserId: String)
    }
    
    let baseEndpointURL: URL
    let apiKey: String
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
        urlRequest.setValue(self.apiKey, forHTTPHeaderField: "X-API-Key")
        return urlRequest
    }
}

extension RemoteReferralClaimCodeRequest.Request {
    
    fileprivate var httpMethod: String {
        switch self {
        case .claim: "POST"
        }
    }
    
    fileprivate func httpBody() throws -> Data? {
        switch self {
        case .claim: nil
        }
    }
    
    fileprivate var path: String {
        switch self {
        case .claim(let code, let appUserId): "referral/users/\(appUserId)/codes/\(code)/claim"
        }
    }
}
