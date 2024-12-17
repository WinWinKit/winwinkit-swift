//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserObservableObject.swift
//
//  Created by Oleh Stasula on 16/12/2024.
//

import SwiftUI

@available(iOS 17.0, *)
@available(macOS 14.0, *)
@Observable
public final class ReferralUserObservableObject: ReferralUserServiceDelegate {
    
    public init(service: ReferralUserService) {
        self.service = service
        self.service.internalDelegate = self
        self.service.startIfNeeded()
    }
    
    public private(set) var referralUser: ReferralUser?
    public private(set) var isRefreshing: Bool = false
    
    // MARK: - ReferralUserServiceDelegate
    
    public func referralUserService(_ service: ReferralUserService, receivedUpdated referralUser: ReferralUser) {
        self.referralUser = referralUser
    }
    
    public func referralUserService(_ service: ReferralUserService, isRefreshingChanged isRefreshing: Bool) {
        self.isRefreshing = isRefreshing
    }
    
    // MARK: - Private
    
    private let service: ReferralUserService
}
