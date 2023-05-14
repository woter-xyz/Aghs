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
  public var toastDuration: Double
  public var transition: AnyTransition
  
  @Published public var isEnabled: Bool = true
  @Published public var isLoading: Bool = false
  @Published public var isEmpty: Bool = false
  @Published public var isToast: Bool = false
  
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
            .onAppear {
              DispatchQueue.main.asyncAfter(
                deadline: .now() + status.toastDuration
              ) {
                status.isToast = false
              }
            }
        }
      }
      .animation(.default, value: status.isToast)
  }
}
