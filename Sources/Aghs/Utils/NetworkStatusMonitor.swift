//
//  NetworkStatusMonitor.swift
//  
//
//  Created by zzzwco on 2023/5/30.
//
//  Copyright (c) 2021 zzzwco <zzzwco@outlook.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Network

/// Responsible for monitoring the network status and interface type.
public final class NetworkStatusMonitor: ObservableObject {
  
  /// Indicates if the device is connected to a network.
  @Published public private(set) var isConnected: Bool = true
  
  /// The network interface type currently in use.
  @Published public private(set) var interfaceType: NWInterface.InterfaceType = .other
  
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkStatusMonitor")
  
  public init() {
    monitor.pathUpdateHandler = {[weak self] path in
      DispatchQueue.main.async {
        self?.isConnected = path.status == .satisfied
        self?.interfaceType = self?.getInterfaceType(from: path) ?? .other
      }
    }
    monitor.start(queue: queue)
  }
  
  private func getInterfaceType(from path: NWPath) -> NWInterface.InterfaceType {
    guard path.status == .satisfied else { return .other }
    
    if let interface = path.availableInterfaces.first(where: { path.usesInterfaceType($0.type) }) {
      return interface.type
    }
    
    return .other
  }
}

