//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  MockErrorResponse.swift
//
//  Created by Oleh Stasula on 29/01/2025.
//

import Foundation

enum MockErrorResponse {
    
    enum NotFound {
        
        static let jsonString: String = """
            {
                "errors": [
                    {
                        "code": "NOT_FOUND",
                        "status": 404,
                        "title": "Not found.",
                        "source": null
                    }
                ]
            }
        """
        
        static let data: Data = Self.jsonString.data(using: .utf8)!
    }
    
    enum PathError {
        
        static let jsonString: String = """
            {
                "errors": [
                    {
                        "code": "PATH_ERROR",
                        "status": 404,
                        "title": "Path error.",
                        "source": null
                    }
                ]
            }
        """
        
        static let data: Data = Self.jsonString.data(using: .utf8)!
    }
    
    enum InternalServerError {
        
        static let jsonString: String = """
            {
                "errors": [
                    {
                        "code": "INTERNAL_SERVER_ERROR",
                        "status": 500,
                        "title": "Internal server error.",
                        "source": null
                    }
                ]
            }
        """
        
        static let data: Data = Self.jsonString.data(using: .utf8)!
    }
}
