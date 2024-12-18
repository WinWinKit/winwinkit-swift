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

protocol NetworkReachabilityDelegate: AnyObject {
    func networkHasBecomeReachable(_ networkReachability: NetworkReachabilityType)
}

protocol NetworkReachabilityType: AnyObject {
    var isReachable: Bool { get }
    var delegate: NetworkReachabilityDelegate? { get set }
    func start()
}

final class NetworkReachability: NetworkReachabilityType, @unchecked Sendable {
        
    init() {
        self.pathMonitor = NWPathMonitor()
        self.isReachable = false
    }
    
    // MARK: - NetworkReachabilityType
    
    private(set) var isReachable: Bool
    
    weak var delegate: NetworkReachabilityDelegate?
    
    func start() {
        self.pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.update(with: path)
            }
        }
        self.pathMonitor.start(queue: DispatchQueue(label: "com.winwinkit.network-reachability"))
        self.isReachable = self.pathMonitor.currentPath.isReachable
    }
    
    // MARK: - Private
    
    private let pathMonitor: NWPathMonitor

    private func update(with path: NWPath) {
        let isReachable = self.isReachable
        self.isReachable = path.isReachable
        if !isReachable && path.isReachable {
            self.delegate?.networkHasBecomeReachable(self)
        }
    }
}

extension NWPath {
    
    fileprivate var isReachable: Bool {
        self.status == .satisfied
    }
}
