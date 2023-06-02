//
//  Popover.swift
//  
//
//  Created by zzzwco on 2023/5/30.
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
import Combine

public extension Ax where T: View {
  
  func popover<C: View>(
    isPresented: Binding<Bool>,
    sourceFrame: CGRect? = nil,
    content: @escaping () -> C
  ) -> some View {
    base.modifier(
      PopoverModifier(
        isPresented: isPresented,
        sourceFrame: sourceFrame,
        popover: content
      )
    )
  }
}

public struct PopoverModifier<C: View>: ViewModifier {
  var isPresented: Binding<Bool>
  var sourceFrame: CGRect?
  let popover: () -> C
  
  @State private var contentFrame: CGRect = .zero
  @EnvironmentObject private var hud: Hud
  
  init(
    isPresented: Binding<Bool>,
    sourceFrame: CGRect?,
    popover: @escaping () -> C
  ) {
    self.isPresented = isPresented
    self.sourceFrame = sourceFrame
    self.popover = popover
    if let sourceFrame {
      self.contentFrame = sourceFrame
    }
  }
  
  public func body(content: Content) -> some View {
    content
      .ax.frameReader {
        if sourceFrame == nil {
          contentFrame = $0
        } else {
          contentFrame = sourceFrame!
        }
      }
      .onChange(of: isPresented.wrappedValue) { newValue in
        if newValue {
          show()
        } else {
          hud.hideAll()
        }
      }
      .onReceive(hud.$isPresented) { output in
        if !output {
          isPresented.wrappedValue = output
        }
      }
  }
  
  private func show() {
    hud.show(animation: .linear(duration: 0.1), transition: .opacity, alignment: .topLeading, ignoresSafeAreaEdges: .all, backgroundColor: .white.opacity(0.00001), interactiveHide: true) {
      ZStack(alignment: popoverAlignment) {
        Color.clear
          .frame(width: popoverContainerWidth, height: popoverContainerHeight)
        popover()
      }
      .offset(x: popoverContainerOffsetX, y: popoverContainerOffsetY)
    }
  }
  
  private var position: Position {
    let hudMidX = hud.frame.midX
    let hudMidY = hud.frame.midY
    let contentCenterX = contentFrame.origin.x + contentFrame.size.width / 2
    let contentCenterY = contentFrame.origin.y + contentFrame.size.height / 2
    if contentCenterX <= hudMidX && contentCenterY <= hudMidY {
      return .downLeft
    } else if contentCenterX > hudMidX && contentCenterY <= hudMidY {
      return .downRight
    } else if contentCenterX <= hudMidX && contentCenterY > hudMidY {
      return .upLeft
    } else {
      return .upRight
    }
  }
  
  private var popoverContainerWidth: CGFloat {
    let width = hud.frame.width
    var res = 0.0
    switch position {
    case .upLeft, .downLeft:
      res = width - contentFrame.origin.x
    case .upRight, .downRight:
      res = contentFrame.maxX
    }
    return res
  }
  
  private var popoverContainerHeight: CGFloat {
    let height = hud.frame.height
    var res = 0.0
    switch position {
    case .downLeft, .downRight:
      res = height - contentFrame.maxY
    case .upLeft, .upRight:
      res = contentFrame.origin.y
    }
    return res
  }
  
  private var popoverContainerOffsetX: CGFloat {
    switch position {
    case .downLeft, .upLeft:
      return contentFrame.origin.x
    case .downRight, .upRight:
      return 0
    }
  }
  
  private var popoverContainerOffsetY: CGFloat {
    switch position {
    case .downLeft, .downRight:
      return contentFrame.maxY
    case .upLeft, .upRight:
      return 0
    }
  }
  
  private var popoverAlignment: Alignment {
    switch position {
    case .downLeft:
      return .topLeading
    case .downRight:
      return .topTrailing
    case .upLeft:
      return .bottomLeading
    case .upRight:
      return .bottomTrailing
    }
  }
  
  private enum Position {
    case downLeft
    case downRight
    case upLeft
    case upRight
  }
}

