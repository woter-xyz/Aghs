//
//  DismissKeyboardOnTap.swift
//  
//
//  Created by zzzwco on 2023/3/29.
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

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Ax where T: View {
  
  /// Dismiss the keyboard when the view is tapped.
  ///
  /// - Returns: A view with a tap gesture that dismisses the keyboard.
  public func dismissKeyboardOnTap() -> some View {
    base.modifier(DismissKeyboardOnTap())
  }
}


/// A view modifier that dismisses the keyboard when the modified view is tapped.
public struct DismissKeyboardOnTap: ViewModifier {
  
  public func body(content: Content) -> some View {
    content
      .background(
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            Aghs.dismissKeyboard()
          }
      )
  }
}
