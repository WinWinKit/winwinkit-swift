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
    /// - Parameter appUserId: Unique identifier of your app's user.
    /// Referral program and rewards will be attached to the `appUserId`.
    /// Use UUID or similar random identifier types.
    /// **Avoid setting person identifying information**, like email or name.
    ///
    /// - Parameter projectKey: The project key to configure ``ReferralUserService`` with.
    /// Obtain ``projectKey`` in the settings of your project in [WinWinKit dashboard](https://app.winwinkit.com).
    ///
    /// - Parameter referralUserCache: Destination for caching referral user data.
    /// The default value is ``UserDefaults.standard``.
    ///
    /// - Returns: An instance of ``ReferralUserService``.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let service = ReferralUserService(appUserId: "<YOUR_APP_USER_ID>",
    ///                                   projectKey: "<YOUR_PROJECT_KEY>")
    /// ```
    ///
    public convenience init(appUserId: String,
                            projectKey: String,
                            referralUserCache: ReferralUserCacheType = UserDefaults.standard) {
        
        let baseEndpointURL = URL(string: "https://app.winwinkit.com/api/")!
        let requestDispatcher = RemoteReferralUserRequestDispatcher(session: .shared)
        let referralUserProvider = RemoteReferralUserProvider(baseEndpointURL: baseEndpointURL,
                                                              requestDispatcher: requestDispatcher)
        self.init(appUserId: appUserId,
                  projectKey: projectKey,
                  referralUserCache: referralUserCache,
                  referralUserProvider: referralUserProvider)
    }
    
    public weak var delegate: ReferralUserServiceDelegate?
    
    public var cachedReferralUser: ReferralUser? {
        do {
            let referralUser = try self.referralUserCache[CacheKeys.referralUser].map { try ReferralUser(jsonData: $0) }
            if referralUser?.appUserId == self.appUserId {
                return referralUser
            }
        }
        catch {
            // TODO: log warning
        }
        return nil
    }
    
    internal init(appUserId: String,
                  projectKey: String,
                  referralUserCache: ReferralUserCacheType,
                  referralUserProvider: ReferralUserProviderType) {
        
        self.appUserId = appUserId
        self.projectKey = projectKey
        self.referralUserCache = referralUserCache
        self.referralUserProvider = referralUserProvider
    }
    
    private let appUserId: String
    private let projectKey: String
    private let referralUserCache: ReferralUserCacheType
    private let referralUserProvider: ReferralUserProviderType
    
    private enum CacheKeys {
        static let referralUser = "com.winwinkit.cache.referralUser"
    }
}
