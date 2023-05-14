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
  
  /// Attach a Hud to the view.
  ///
  /// - Parameter hud: A `Hud` instance to be attached to the view.
  /// - Returns: The original view with the Hud modifier applied.
  func initHud(_ hud: Hud, defaultStyle: HudStyle = Hud.defaultStyle) -> some View {
    Hud.defaultStyle = defaultStyle
    return base.modifier(HudModifier(hud: hud))
  }
  
  func hud(
    isPresented: Binding<Bool>,
    style: HudStyle = Hud.defaultStyle,
    @ViewBuilder content: @escaping () -> some View
  ) -> some View {
    base.modifier(
      HudViewModifier(
        isPresented: isPresented,
        style: style
      ) {
        content()
      }
    )
  }
}

public struct HudViewModifier<C: View>: ViewModifier {
  @Binding var isPresented: Bool
  var style: HudStyle
  @ViewBuilder var hudView: () -> C
  @EnvironmentObject var hud: Hud
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: isPresented) { newValue in
        if newValue {
          hud.show(style: style) {
            hudView()
          }
        } else {
          hud.hide()
        }
      }
  }
}

/// A Hud that can be displayed on a view.
///
/// Best practice example:
///
/// First, add a Hud instance to app:
///
/// ```swift
/// ```
///
/// Then you can use hud in any view of the app:
///
public final class Hud: ObservableObject {
  @Published public var isPresented = false
  public static var defaultStyle: HudStyle = .default
  
  var content: AnyView = AnyView(EmptyView())
  var style: HudStyle = .default
  
  public init() {}
  
  public func show(
    style: HudStyle = Hud.defaultStyle,
    @ViewBuilder content: () -> some View
  ) {
    self.style = style
    self.content = AnyView(content())
    withAnimation(.default) {
      isPresented = true
    }
  }
  
  /// Hide the Hud with the specified animation.
  ///
  /// - Parameter animation: The animation to use when hiding the Hud.
  public func hide() {
    withAnimation(.default) {
      isPresented = false
    }
  }
}

/// A view modifier that adds a Hud to the view.
public struct HudModifier: ViewModifier {
  @StateObject public var hud: Hud
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        hud.style.background
          .ignoresSafeArea()
          .onTapGesture {
            if hud.style.interactiveHide {
              hud.hide()
            }
          }
          .opacity(hud.isPresented ? 1 : 0)
          .overlay(alignment: hud.style.alignment) {
            if hud.isPresented {
              hud.content
                .transition(hud.style.transition)
            }
          }
      }
      .environmentObject(hud)
  }
}

public protocol HudStyle {
  var background: AnyView { get }
  var interactiveHide: Bool { get }
  var alignment: Alignment { get }
  var transition: AnyTransition { get }
}

public extension HudStyle {
  var background: AnyView { AnyView(Color.black.opacity(0.6)) }
  var interactiveHide: Bool { true }
  var alignment: Alignment { .center }
  var transition: AnyTransition { .opacity.combined(with: .scale) }
}

public struct DefaultHudStyle: HudStyle {}

extension HudStyle where Self == DefaultHudStyle {
  
  public static var `default`: DefaultHudStyle {
    .init()
  }
}

public struct CustomHudStyle: HudStyle {
  public var background: AnyView
  public var interactiveHide: Bool
  public var alignment: Alignment
  public var transition: AnyTransition
  
  public init(
    background: AnyView,
    interactiveHide: Bool,
    alignment: Alignment,
    transition: AnyTransition
  ) {
    self.background = background
    self.interactiveHide = interactiveHide
    self.alignment = alignment
    self.transition = transition
  }
}

extension HudStyle where Self == CustomHudStyle {
  
  public static func custom(
    background: AnyView,
    interactiveHide: Bool,
    alignment: Alignment,
    transition: AnyTransition
  ) -> CustomHudStyle {
    .init(
      background: background,
      interactiveHide: interactiveHide,
      alignment: alignment,
      transition: transition
    )
  }
}


