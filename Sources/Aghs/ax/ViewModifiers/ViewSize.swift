//
//  File.swift
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

public extension Ax where T: View {
  
  func onChangeOfSize(perform action: @escaping (CGSize) -> Void) -> some View {
    base.modifier(Aghs.Bag.SizeModifer(onChange: action))
  }
}

public extension Aghs.Bag {
  
  struct SizeModifer: ViewModifier {
    public let onChange: (CGSize) -> Void
    
    public func body(content: Content) -> some View {
      content
        .background(
          GeometryReader { gp in
            Color.clear
              .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) {
                gp[$0]
              }
              .onPreferenceChange(BoundsPreferenceKey.self) {
                onChange($0.size)
              }
          }
        )
    }
  }
  
  struct BoundsPreferenceKey: PreferenceKey {
    
    public static var defaultValue: CGRect = .zero
    
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
      value = nextValue()
    }
  }
}
