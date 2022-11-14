//
//  IntEx.swift
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

extension Int: AxBoxable {}

public extension AxBox where T == Int {
  
  #if canImport(UIKit)
  /// Rational width with referWidth.
  /// - Parameter referWidth: Default is 375.
  func widthRatio(_ referWidth: CGFloat = 375.0) -> CGFloat {
    return CGFloat(base.self).ax.widthRatio(referWidth)
  }
  
  /// Rational height with referHeight.
  /// - Parameter referHeight: Default is 812.
  func heightRatio(_ referHeight: CGFloat = 812.0) -> CGFloat {
    return CGFloat(base.self).ax.heightRatio(referHeight)
  }
  #endif
}
