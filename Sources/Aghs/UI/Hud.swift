//
//  Hud.swift
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
  
  func hud(_ hud: Hud) -> some View {
    base.modifier(Aghs.Bag.HudModifier(hud: hud))
  }
}

public final class Hud: ObservableObject {
  @Published public var isPresented = false
  var content: any View = EmptyView()
  var style: HudStyle = .default()
  
  public init() {}
  
  public func show(
    style: HudStyle = .default(),
    animation: Animation? = .spring(),
    content: () -> some View
  ) {
    self.style = style
    self.content = content()
    withAnimation(animation) {
      isPresented = true
    }
  }
  
  public func hide(_ animation: Animation? = .spring()) {
    withAnimation(animation) {
      isPresented = false
    }
  }
}

public extension Aghs.Bag {
  
  struct HudModifier: ViewModifier {
    @StateObject public var hud: Hud
    private var transition: AnyTransition {
      switch hud.style {
      case is TipHudStyle:
        return (hud.style as! TipHudStyle).position.transition
      default:
        return .opacity.combined(with: .scale)
      }
    }
    
    public func body(content: Content) -> some View {
      ZStack(alignment: hud.style.position.alignment) {
        content
        
        if hud.isPresented {
          Group {
            AnyView(hud.style.background)
              .ignoresSafeArea()
              .transition(.opacity)
              .onTapGesture {
                if hud.style.interactiveHide {
                  hud.hide()
                }
              }
              .onAppear {
                if let duration = hud.style.duration {
                  DispatchQueue.main.asyncAfter(
                    deadline: .now() + duration) {
                      hud.hide()
                    }
                }
              }
            
            AnyView(hud.content)
              .transition(transition)
          }
          .zIndex(.infinity)
        }
      }
      .environmentObject(hud)
    }
  }
}

public protocol HudStyle {
  var background: any View { get set }
  var interactiveHide: Bool { get set }
  var duration: Double? { get set }
  var position: Aghs.Bag.HudContentPosition { get set }
}

public extension HudStyle where Self == Aghs.Bag.DefaultHudStyle {
  
  static func `default`(
    background: any View = Color.black.opacity(0.6),
    interactiveHide: Bool = true,
    duration: Double? = nil,
    position: Aghs.Bag.HudContentPosition = .center
  ) -> Aghs.Bag.DefaultHudStyle {
    .init(
      background: background,
      interactiveHide: interactiveHide,
      duration: duration,
      position: position
    )
  }
}

public extension HudStyle where Self == Aghs.Bag.TipHudStyle {
  
  static func tip(
    style: Aghs.Bag.TipStyle = .default(),
    duration: Double? = 2.0,
    position: Aghs.Bag.HudContentPosition = .center
  ) -> Aghs.Bag.TipHudStyle {
    var background: any View = Color.clear
    var interactiveHide = true
    var duration = duration
    switch style {
    case .default(let value):
      background = value ?? Color.clear
    case .loading(let value):
      background = value ?? Color.black.opacity(0.0001)
      interactiveHide = false
      duration = nil
    }
    return .init(
      background: background,
      interactiveHide: interactiveHide,
      duration: duration,
      position: position
    )
  }
}

public extension Aghs.Bag {
  
  enum HudContentPosition {
    case top
    case center
    case bottom
    
    var alignment: Alignment {
      switch self {
      case .top:
        return .top
      case .center:
        return .center
      case .bottom:
        return .bottom
      }
    }
    
    var transition: AnyTransition {
      switch self {
      case .top:
        return .opacity.combined(with: .move(edge: .top))
      case .bottom:
        return .opacity.combined(with: .move(edge: .bottom))
      case .center:
        return .opacity.combined(with: .scale)
      }
    }
  }
  
  struct DefaultHudStyle: HudStyle {
    public var background: any View
    public var interactiveHide: Bool
    public var duration: Double?
    public var position: HudContentPosition
  }
  
  struct TipHudStyle: HudStyle {
    public var background: any View
    public var interactiveHide: Bool
    public var duration: Double?
    public var position: HudContentPosition
  }
  
  enum TipStyle {
    case `default`(background: (any View)? = nil)
    case loading(background: (any View)? = nil)
  }
}
