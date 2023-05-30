//
//  ViewFrame.swift
//  
//
//  Created by zzzwco on 2022/11/16.
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

extension Ax where T: View {
  
  /// Retrieve the frame of the view and call a callback function with the frame.
  ///
  /// - Parameter callback: A closure that takes the frame of the view as a parameter.
  /// - Returns: The original view with a background modifier that captures the view's frame.
  public func getFrame(_ callback: @escaping (CGRect) -> Void) -> some View {
    base.modifier(FrameModifier(callback: callback))
  }
}

/// A view modifier that captures the frame of the view and calls a callback function with the frame.
public struct FrameModifier: ViewModifier {
  public let callback: (CGRect) -> Void
  
  public func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometryProxy in
          Color.clear
            .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: .global))
        }
      )
      .onPreferenceChange(FramePreferenceKey.self, perform: callback)
  }
}

/// A preference key for storing the view's frame.
public struct FramePreferenceKey: PreferenceKey {
  public static var defaultValue: CGRect = .zero
  
  public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}
