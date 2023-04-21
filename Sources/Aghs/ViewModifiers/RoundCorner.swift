//
//  RoundCorner.swift
//  
//
//  Created by zzzwco on 2023/2/16.
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
//public typealias RectCorner = UIRectCorner
#elseif canImport(AppKit)
import AppKit
//public typealias RectCorner = Aghs.Bag.NSRectCorner
#endif

extension Ax where T: View {
  
  /// Apply rounded corners to specific corners of the view.
  ///
  /// - Parameters:
  ///   - radius: The corner radius to be applied.
  ///   - corners: The specific corners to be rounded.
  /// - Returns: The original view with rounded corners.
  public func roundedCorners(_ radius: CGFloat, corners: Aghs.Bag.RectCorner) -> some View {
    base.clipShape(Aghs.Bag.RoundedCorners(radius: radius, corners: corners))
  }
}

extension Aghs.Bag {
  #if canImport(UIKit)
  public typealias RectCorner = UIRectCorner
  #elseif canImport(AppKit)
  public typealias RectCorner = Aghs.Bag.NSRectCorner
  #endif
  
  /// A shape representing a rectangle with rounded corners.
  public struct RoundedCorners: Shape {
    public var radius: CGFloat = .zero
    public var corners: RectCorner = .allCorners
    
    public func path(in rect: CGRect) -> Path {
      var path: Path
      #if canImport(UIKit)
      let bezierPath = UIBezierPath(
        roundedRect: rect,
        byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius)
      )
      path = Path(bezierPath.cgPath)
      #elseif canImport(AppKit)
      path = .init()
      let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
      let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

      let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
      let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

      let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
      let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

      let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
      let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )
      
      path.move(to: p1)
      path.addArc(
        tangent1End: CGPoint(x: rect.minX, y: rect.minY),
        tangent2End: p2,
        radius: radius
      )
      path.addLine(to: p3)
      path.addArc(
        tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
        tangent2End: p4,
        radius: radius
      )
      path.addLine(to: p5)
      path.addArc(
        tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
        tangent2End: p6,
        radius: radius
      )
      path.addLine(to: p7)
      path.addArc(
        tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
        tangent2End: p8,
        radius: radius
      )
      path.closeSubpath()
      #endif
      
      return path
    }
  }
  
  public struct NSRectCorner: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    public static let topLeft = NSRectCorner(rawValue: 1 << 0)
    public static let topRight = NSRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
    public static let allCorners: NSRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
  }
}
