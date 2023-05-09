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

extension Ax where T: View {
  
  /// Attach a Hud to the view.
  ///
  /// - Parameter hud: A `Hud` instance to be attached to the view.
  /// - Returns: The original view with the Hud modifier applied.
  public func hud(_ hud: Hud) -> some View {
    base.modifier(Aghs.Bag.HudModifier(hud: hud))
  }
}

/// A Hud that can be displayed on a view.
///
/// Best practice example:
///
/// First, add a Hud instance to app:
///
/// ```swift
/// @main
/// struct Aghs_exampleApp: App {
///   @StateObject private var hud = Hud()
///
///   init() {
///     Hud.defaultStyle = .default(background: Color.yellow.opacity(0.35))
///   }
///
///   var body: some Scene {
///     WindowGroup {
///       HomeView()
///         .ax.hud(hud)
///     }
///   }
/// }
/// ```
///
/// Then you can use hud in any view of the app:
///
/// ```swift
/// struct HudView: View {
///   @EnvironmentObject var hud: Hud
///
///   var body: some View {
///     VStack {
///       Button("Show") {
///         hud.show {
///           DismissButton()
///         }
///       }
///       .padding(50)
///     }
///   }
/// }
///
/// struct DismissButton: View {
///   @EnvironmentObject var hud: Hud
///
///   var body: some View {
///     Button("Dismiss") {
///       hud.hide(.spring())
///     }
///   }
/// }
/// ```
@MainActor
public final class Hud: ObservableObject {
  @Published public var isPresented = false
  var content: any View = EmptyView()
  var style: HudStyle = .default()
    
  public static var defaultStyle: HudStyle = .default()
  
  public init() {}
  
  /// Display the Hud with the specified style, animation, and content.
  ///
  /// - Parameters:
  ///   - style: A `HudStyle` instance specifying the appearance and behavior of the Hud.
  ///   - animation: The animation to use when showing the Hud.
  ///   - content: A closure that returns the content of the Hud.
  public func show(
    style: HudStyle,
    animation: Animation? = .spring(),
    content: () -> some View
  ) {
    self.style = style
    self.content = content()
    withAnimation(animation) {
      isPresented = true
    }
  }
  
  /// Display the Hud using the global default style, a specified animation, and content.
  ///
  /// This method uses the global `defaultStyle` as the Hud style.
  ///
  /// - Parameters:
  ///   - animation: The animation to use when showing the Hud. Defaults to `.spring()`.
  ///   - content: A closure that returns the content of the Hud.
  public func show(
    animation: Animation? = .spring(),
    content: () -> some View
  ) {
    show(style: Self.defaultStyle, animation: animation, content: content)
  }
  
  /// Hide the Hud with the specified animation.
  ///
  /// - Parameter animation: The animation to use when hiding the Hud.
  public func hide(_ animation: Animation? = .spring()) {
    withAnimation(animation) {
      isPresented = false
    }
  }
}

extension Aghs.Bag {
  
  /// A view modifier that adds a Hud to the view.
  public struct HudModifier: ViewModifier {
    @StateObject public var hud: Hud
    
    public func body(content: Content) -> some View {
      ZStack(alignment: hud.style.alignment) {
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
              .transition(hud.style.transiton)
          }
          .zIndex(.infinity)
        }
      }
      .environmentObject(hud)
      .ignoresSafeArea()
    }
  }
}

public protocol HudStyle {
  var background: any View { get set }
  var interactiveHide: Bool { get set }
  var alignment: Alignment { get set }
  var transiton: AnyTransition { get set }
  var duration: Double? { get set }
}

extension HudStyle where Self == Aghs.Bag.DefaultHudStyle {
  
  public static func `default`(
    background: any View = Color.black.opacity(0.6),
    interactiveHide: Bool = true,
    alignment: Alignment = .center,
    transiton: AnyTransition = .opacity.combined(with: .scale),
    duration: Double? = nil
  ) -> Aghs.Bag.DefaultHudStyle {
    .init(
      background: background,
      interactiveHide: interactiveHide,
      alignment: alignment,
      transiton: transiton,
      duration: duration
    )
  }
}

extension Aghs.Bag {
  
  public struct DefaultHudStyle: HudStyle {
    public var background: any View
    public var interactiveHide: Bool
    public var alignment: Alignment
    public var transiton: AnyTransition
    public var duration: Double?
  }
}
