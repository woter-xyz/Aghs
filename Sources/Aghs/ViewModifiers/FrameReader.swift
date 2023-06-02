//
//  FrameReader.swift
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
  
  /// This function allows for reading the frame of a view within a specified coordinate space.
  ///
  /// > Tip: The correct frame can only be obtained after the view rendering is completed.
  ///
  /// - Parameters:
  ///   - coordinateSpace: The `CoordinateSpace` in which the frame is to be read. Default is `.global`.
  ///   - frame: A closure that takes `CGRect` as a parameter. This closure is called with the frame of the view.
  ///
  /// - Returns: A `View` after applying the `FrameReaderModifier`.
  func frameReader(
    in coordinateSpace: CoordinateSpace = .global,
    _ frame: @escaping (CGRect) -> Void
  ) -> some View {
    base.modifier(FrameReaderModifier(coordinateSpace: coordinateSpace, frame: frame))
  }
}

/// A `ViewModifier` that captures the frame of the view in the provided `CoordinateSpace`
/// and calls the provided callback function with the frame.
public struct FrameReaderModifier: ViewModifier {
  let coordinateSpace: CoordinateSpace
  let frame: (CGRect) -> Void
  
  public func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometryProxy in
          let rect = geometryProxy.frame(in: coordinateSpace)
          Color.clear
            .preference(key: FramePreferenceKey.self, value: rect)
            .onAppear {
              frame(rect)
            }
        }
      )
      .onPreferenceChange(FramePreferenceKey.self, perform: frame)
  }
}

/// A `PreferenceKey` for storing the frame of a view.
public struct FramePreferenceKey: PreferenceKey {
  public static var defaultValue: CGRect = .zero
  
  public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}
