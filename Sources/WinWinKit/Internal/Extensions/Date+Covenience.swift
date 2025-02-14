//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  Date+Covenience.swift
//
//  Created by Oleh Stasula on 14/02/2025.
//

import Foundation

extension Date {
    
    func isPracticallyTheSame(as date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.compare(self, to: date, toGranularity: .second) == .orderedSame
    }
}
