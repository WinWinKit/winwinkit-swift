//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  UserServiceDelegate.swift
//
//  Created by Oleh Stasula on 20/05/2025.
//

protocol UserServiceDelegate: AnyObject {
    func userServiceCanPerformNextRefresh(_ service: UserService) -> Bool
    func userService(_ service: UserService, receivedUpdated user: User)
    func userService(_ service: UserService, receivedError error: Error)
}
