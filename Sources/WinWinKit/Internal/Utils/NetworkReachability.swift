//
//  Copyright WinWinKit. All Rights Reserved.
//
//  Licensed under the MIT License (the "License").
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//
//  NetworkReachability.swift
//
//  Created by Oleh Stasula on 11/12/2024.
//

import Network

protocol NetworkReachabilityType: AnyObject {
    var isReachable: Bool { get }
    var hasBecomeReachable: (() -> Void)? { get set }
    var hasBecomeUnreachable: (() -> Void)? { get set }
    func start()
}

final class NetworkReachability: NetworkReachabilityType, @unchecked Sendable {
        
    init() {
        self.pathMonitor = NWPathMonitor()
        self.isReachable = false
    }
    
    // MARK: - NetworkReachabilityType
    
    private(set) var isReachable: Bool
    
    var hasBecomeReachable: (() -> Void)?
    
    var hasBecomeUnreachable: (() -> Void)?
    
    func start() {
        self.pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.update(with: path)
        }
        self.pathMonitor.start(queue: DispatchQueue(label: "com.winwinkit.network-reachability"))
        self.isReachable = self.pathMonitor.currentPath.isReachable
    }
    
    // MARK: - Private
    
    private let pathMonitor: NWPathMonitor

    private func update(with path: NWPath) {
        if !self.isReachable && path.isReachable {
            self.hasBecomeReachable?()
        }
        else if self.isReachable && !path.isReachable {
            self.hasBecomeUnreachable?()
        }
    }
}

extension NWPath {
    
    fileprivate var isReachable: Bool {
        self.status == .satisfied
    }
}
