//
//  ViewStatus.swift
//  
//
//  Created by zzzwco on 2023/5/11.
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
import SwiftUI

public extension Ax where T: View {
  
  /// Applies several view status modifiers to a view.
  ///
  /// - Parameters:
  ///   - status: The `ViewStatusManager` instance to track view states.
  ///   - toastView: The view to show when toast status is enabled.
  ///   - loadingView: The view to show when loading status is enabled.
  ///   - emptyView: The view to show when empty status is enabled.
  /// - Returns: A view with applied status modifiers.
  func viewStatus<E: View, T: View, L: View>(
    _ status: ViewStatusManager,
    toastView: @escaping () -> T = { EmptyView() },
    loadingView: @escaping () -> L = { ProgressView() },
    emptyView: @escaping () -> E = { EmptyView() }
  ) -> some View {
    base
      .modifier(EnabledModifier())
      .modifier(EmptyModifier { emptyView() })
      .modifier(ToastModifier { toastView() })
      .modifier(LoadingModifier { loadingView() })
      .environmentObject(status)
  }
}

public class ViewStatusManager: ObservableObject {
  /// Duration for showing toast messages.
  public var toastDuration: Double
  
  /// Transition to use when a status view appears or disappears.
  public var transition: AnyTransition
  
  @Published public var isEnabled: Bool = true
  @Published public var isLoading: Bool = false
  @Published public var isEmpty: Bool = false
  @Published public var toast: String = ""
  @Published public var isToast: Bool = false {
    didSet {
      toastTimer?.cancel()
      
      if isToast {
        let timer = DispatchWorkItem {
          self.isToast = false
        }
        
        self.toastTimer = timer
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration, execute: timer)
      }
    }
  }
  
  private var toastTimer: DispatchWorkItem?
  
  /// Initialize a new instance of `ViewStatusManager`.
  ///
  /// - Parameters:
  ///   - toastDuration: Duration for showing toast messages.
  ///   - transtion: Transition to use when a status view appears or disappears.
  public init(
    toastDuration: Double = 1.5,
    transtion: AnyTransition = .opacity.combined(with: .scale)
  ) {
    self.toastDuration = toastDuration
    self.transition = transtion
  }
}

public struct EnabledModifier: ViewModifier {
  @EnvironmentObject private var status: ViewStatusManager
  
  public func body(content: Content) -> some View {
    content
      .disabled(!status.isEnabled)
  }
}

public struct LoadingModifier<C: View>: ViewModifier {
  @ViewBuilder public var statusView: () -> C
  @EnvironmentObject private var status: ViewStatusManager
  @State private var contentSize = CGSize.zero
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        if status.isLoading {
          Color.white.opacity(0.00001)
          
          statusView()
            .transition(status.transition)
        }
      }
      .animation(.default, value: status.isLoading)
  }
}



public struct EmptyModifier<C: View>: ViewModifier {
  @ViewBuilder public var statusView: () -> C
  @EnvironmentObject private var status: ViewStatusManager
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        if status.isEmpty {
          statusView()
            .transition(status.transition)
        }
      }
      .animation(.default, value: status.isEmpty)
  }
}

public struct ToastModifier<C: View>: ViewModifier {
  @ViewBuilder public var statusView: () -> C
  @EnvironmentObject private var status: ViewStatusManager
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        if status.isToast {
          statusView()
            .zIndex(999999)
            .transition(status.transition)
        }
      }
      .animation(.default, value: status.isToast)
  }
}
