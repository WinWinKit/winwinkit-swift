//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralUserService.swift
//
//  Created by Oleh Stasula on 04/12/2024.
//

import Foundation

public final class ReferralUserService {
    
    ///
    /// Initialize an instance of the ``ReferralUserService`.
    ///
    /// - Parameter projectKey: The project key to configure ``ReferralUserService`` with.
    /// Obtain ``projectKey`` in the settings of your project in [WinWinKit dashboard](https://app.winwinkit.com).
    ///
    /// - Parameter userId: Unique identifier of your app's user.
    /// Referral program and rewards will be attached to the `userId`.
    /// Use UUID or similar random identifier types.
    /// **Avoid setting person identifying information**, like email or name.
    ///
    /// - Parameter referralUserCache: Destination for caching referral user data.
    /// The default value is ``UserDefaults.standard``.
    ///
    /// - Returns: An instance of ``ReferralUserService``.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let service = ReferralUserService(projectKey: "<YOUR_PROJECT_KEY>",
    ///                                   userId: "<YOUR_APP_USER_ID>")
    /// ```
    ///
    public convenience init(projectKey: String,
                            userId: String,
                            referralUserCache: ReferralUserCacheType = UserDefaults.standard) {
        
        let baseEndpointURL = URL(string: "https://app.winwinkit.com/api/")!
        let requestDispatcher = RemoteReferralUserRequestDispatcher(session: .shared)
        let referralUserProvider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                              requestDispatcher: requestDispatcher)
        self.init(projectKey: projectKey,
                  userId: userId,
                  referralUserCache: referralUserCache,
                  referralUserProvider: referralUserProvider)
    }
    
    public weak var delegate: ReferralUserServiceDelegate?
    
    internal init(projectKey: String,
                  userId: String,
                  referralUserCache: ReferralUserCacheType,
                  referralUserProvider: ReferralUserProviderType) {
        
        self.projectKey = projectKey
        self.userId = userId
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
    }
    
    private let projectKey: String
    private let userId: String
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private enum CacheKeys {
        static let referralUser = "com.winwinkit.cache.referralUser"
    }
}
