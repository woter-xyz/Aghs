//
//  CGFloatEx.swift
//  
//
//  Created by zzzwco on 2022/11/11.
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

extension CGFloat: Axable {}

extension Ax where T == CGFloat {
  
  #if canImport(UIKit)
  /// Calculates the proportional width based on a reference width.
  /// - Parameter referenceWidth: The width to which the proportion is calculated. Default is 375.
  @available(iOS 16, *)
  public func proportionalWidth(_ referenceWidth: CGFloat = 375.0) -> CGFloat {
    return UIScreen.ax.width * base.self / referenceWidth
  }
  
  /// Calculates the proportional height based on a reference height.
  /// - Parameter referenceHeight: The height to which the proportion is calculated. Default is 812.
  @available(iOS 16, *)
  public func proportionalHeight(_ referenceHeight: CGFloat = 812.0) -> CGFloat {
    return UIScreen.ax.height * base.self / referenceHeight
  }
  #endif
}
