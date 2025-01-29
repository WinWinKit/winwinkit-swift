//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  RemoteRequestDispatcherErrorTests.swift
//
//  Created by Oleh Stasula on 29/01/2025.
//

import Foundation
import Testing
@testable import WinWinKit

@Suite struct RemoteRequestDispatcherErrorTests {
    
    @Test func success() {
        #expect(RemoteRequestDispatcherError(statusCode: 200, data: nil) == nil)
        #expect(RemoteRequestDispatcherError(statusCode: 201, data: nil) == nil)
        #expect(RemoteRequestDispatcherError(statusCode: 299, data: nil) == nil)
        #expect(RemoteRequestDispatcherError(statusCode: 299, data: MockErrorResponse.NotFound.data) == nil)
    }
    
    @Test func notFound() {
        #expect(RemoteRequestDispatcherError(statusCode: 404, data: MockErrorResponse.NotFound.data) == .notFound)
        #expect(RemoteRequestDispatcherError(statusCode: 404, data: nil) != .notFound)
    }
    
    @Test func unknown() {
        #expect(RemoteRequestDispatcherError(statusCode: 404, data: nil) == .unknown)
        #expect(RemoteRequestDispatcherError(statusCode: 404, data: MockErrorResponse.PathError.data) == .unknown)
        #expect(RemoteRequestDispatcherError(statusCode: 500, data: MockErrorResponse.InternalServerError.data) == .unknown)
        #expect(RemoteRequestDispatcherError(statusCode: 123, data: MockErrorResponse.PathError.data) == .unknown)
    }
}
