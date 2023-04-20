//
//  NavBackButton.swift
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

extension Ax where T: View {
  
  /// Add a custom navigation back button to the view.
  ///
  /// - Parameter label: A closure that returns the custom button's view.
  /// - Returns: The original view with the custom navigation back button.
  public func customNavBackButton<C: View>(label: @escaping () -> C) -> some View {
    base.modifier(Aghs.Bag.CustomNavBackButton(label: label))
  }
}

extension Aghs.Bag {
  
  /// A view modifier that adds a custom navigation back button to the view.
  public struct CustomNavBackButton<C: View>: ViewModifier {
    @ViewBuilder public var label: () -> C
    @Environment(\.dismiss) private var dismiss
    
    public func body(content: Content) -> some View {
      content
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              dismiss()
            } label: {
              label()
            }
          }
        }
    }
  }
}

/**
 Solve the problem that the interactive pop gesture(swipe from the left edge) fails when customizing the back button of the navigation bar.
 */
extension UINavigationController {
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = nil
  }
}
#endif
