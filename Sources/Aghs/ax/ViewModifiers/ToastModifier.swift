//
//  ToastModifier.swift
//  
//
//  Created by zzzwco on 2022/12/2.
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
  
  func toast<C: View>(
    isPresented: Binding<Bool>,
    style: Aghs.Bag.Toast.Style = .default(),
    position: Aghs.Bag.Toast.Position = .top,
    @ViewBuilder content: @escaping () -> C
  ) -> some View {
    base.modifier(
      Aghs.Bag.ToastModifier(
        isPresented: isPresented,
        style: style,
        postion: position,
        content: content
      )
    )
  }
}

public extension Aghs.Bag {
  
  struct ToastModifier<C: View>: ViewModifier {
    public var isPresented: Binding<Bool>
    public let style: Toast.Style
    public let postion: Toast.Position
    public let toastContent: () -> C
    @State private var contentSize = CGSize.zero
    
    init(
      isPresented: Binding<Bool>,
      style: Toast.Style,
      postion: Toast.Position,
      @ViewBuilder content: @escaping () -> C
    ) {
      self.isPresented = isPresented
      self.style = style
      self.postion = postion
      self.toastContent = content
    }
    
    public func body(content: Content) -> some View {
      ZStack(alignment: postion.alignment) {
        content
          .ax.onChangeOfSize { size in
            self.contentSize = size
          }
        
        if isPresented.wrappedValue {
          if case .loading = style {
            Color.white.opacity(0.00001)
              .frame(width: contentSize.width, height: contentSize.height)
          }
          
          toastContent()
            .transition(postion.transition)
            .zIndex(99999)
            .onAppear {
              if case let .default(duration) = style {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                  self.isPresented.wrappedValue = false
                }
              }
            }
        }
      }
      .animation(.default, value: isPresented.wrappedValue)
    }
  }
}

public extension Aghs.Bag {
  
  struct Toast {
    public enum Position {
      case top
      case center
      case bottom
      
      var alignment: Alignment {
        switch self {
        case .top:
          return .top
        case .center:
          return .center
        case .bottom:
          return .bottom
        }
      }
      
      var transition: AnyTransition {
        switch self {
        case .top:
          return .opacity
            .combined(with: .scale)
            .combined(with: .move(edge: .top))
        case .bottom:
          return .opacity
            .combined(with: .scale)
            .combined(with: .move(edge: .bottom))
        case .center:
          return .opacity
            .combined(with: .scale)
        }
      }
    }
    
    public enum Style {
      case `default`(duration: Double = 2)
      case loading
    }
  }
}
