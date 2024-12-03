//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  WinWinKit.swift
//
//  Created by Oleh Stasula on 03/12/2024.
//

///
/// The entry point for WinWinKit SDK.
/// Normally it should be instantiated as soon as your app has a unique user id for your user.
/// This can be when a user logs in if you have accounts or on launch if you can generate a random user identifier.
///
public final class WinWinKit {
    
    ///
    /// Initialize an instance of the WinWinKit SDK.
    ///
    /// - Parameter projectKey: The project key you wish to use to configure ``WinWinKit``.
    ///
    /// - Returns: An instance of ``WinWinKit`` object.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let winWinKit = WinWinKit(projectKey: "<YOUR_PROJECT_KEY>")
    /// ```
    ///
    public init(projectKey: String) {
        self.projectKey = projectKey
    }
    
    private let projectKey: String
}
