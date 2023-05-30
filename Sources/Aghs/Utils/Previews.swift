//
//  Previews.swift
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

import SwiftUI

extension Aghs {
  
  /// Previews the specified view on multiple devices.
  ///
  /// - Parameters:
  ///   - preview: The view to be previewed.
  ///   - devices: An array of `PreviewDevices` to preview the view on.
  ///   - viewName: An optional name for the view that is displayed in the preview (default is an empty string).
  /// - Returns: A view group containing the specified view previewed on the specified devices.
  public static func previews(
    _ preview: some View,
    devices: [PreviewDevices],
    viewName: String = ""
  ) -> some View {
    Group {
      ForEach(devices, id: \.self) { device in
        preview
          .previewDevice(.init(rawValue: device.rawValue))
          .previewDisplayName("\(device.rawValue) \(viewName)")
      }
    }
  }
}

/// A list of devices to be used for SwiftUI previews.
public enum PreviewDevices: String {
  
  case iPhone_13_Pro = "iPhone 13 Pro"
  case iPhone_13_Pro_Max = "iPhone 13 Pro Max"
  case iPhone_13_mini = "iPhone 13 mini"
  case iPhone_13 = "iPhone 13"
  case iPhone_SE_3rd_generation = "iPhone SE (3rd generation)"
  case iPhone_14 = "iPhone 14"
  case iPhone_14_Plus = "iPhone 14 Plus"
  case iPhone_14_Pro = "iPhone 14 Pro"
  case iPhone_14_Pro_Max = "iPhone 14 Pro Max"
  case iPad_Air_5th_generation = "iPad Air (5th generation)"
  case iPad_mini_6th_generation = "iPad mini (6th generation)"
  case iPad_Pro_11_inch_4th_generation = "iPad Pro (11-inch) (4th generation)"
  case iPad_Pro_12_9_inch_6th_generation = "iPad Pro (12.9-inch) (6th generation)"
  case Apple_Watch_SE_40mm = "Apple Watch SE (40mm)"
  case Apple_Watch_SE_44mm = "Apple Watch SE (44mm)"
  case Apple_Watch_Series_8_41mm = "Apple Watch Series 8 (41mm)"
  case Apple_Watch_Series_8_45mm = "Apple Watch Series 8 (45mm)"
  case Apple_Watch_Ultra_49mm = "Apple Watch Ultra (49mm)"
  case Mac = "Mac"
}
