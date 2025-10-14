//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  ReferralsError+Convenience.swift
//
//  Created by Oleh Stasula on 14/10/2025.
//

import Foundation

extension ReferralsError {
    static func fromErrorResponse(_ error: Error) -> Self? {
        guard
            let errorResponse = error as? ErrorResponse,
            case .error(_, let data, _, _) = errorResponse,
            let data
        else { return nil }
        
        let errorsResponse = try? JSONDecoder().decode(ErrorsResponse.self, from: data)
        
        return .requestFailure(errorsResponse?.errors ?? [])
    }
}
