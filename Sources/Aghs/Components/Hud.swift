//
//  Hud.swift
//  
//
//  Created by zzzwco on 2023/5/25.
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
  
  /// Initialize a HUD with the specified configurations.
  /// - Parameters:
  ///   - backgroundColor: The background color of the HUD. Default value is black with opacity of 0.5.
  ///   - interactiveHide: A Boolean value that determines whether the HUD should be hidden when a tap gesture is detected. Default value is `false`.
  ///   - animation: The animation to be used for showing and hiding the HUD. Default value is linear animation with a duration of 0.1 seconds.
  /// - Returns: A `View` with the specified HUD configurations.
  func initHud(
    backgroundColor: Color = .black.opacity(0.5),
    interactiveHide: Bool = false,
    animation: Animation = .linear(duration: 0.1)
  ) -> some View {
    base.modifier(
      HudModifier(hud: .init(
        backgroundColor: backgroundColor,
        interactiveHide: interactiveHide,
        animation: animation
      ))
    )
  }
}

/// An `ObservableObject` for managing a Heads-Up Display (HUD).
public final class Hud: ObservableObject {
  
  @Published private(set) var isPresented = false
  @Published var contents: [HudContent<AnyHashable, AnyView>] = []
  var currentAnimation: Animation
  var currentBackgroundColor: Color {
    contents.last?.backgroundColor ?? defaultBackgroundColor
  }
  var currentInteractiveHide: Bool {
    contents.last?.interactiveHide ?? defaultInteractiveHide
  }
  
  private var defaultBackgroundColor: Color
  private var defaultInteractiveHide: Bool
  private var defaultAnimation: Animation
  private var bag = Set<AnyCancellable>()
  
  /// Initialize a new `Hud` with the specified configurations.
  /// - Parameters:
  ///   - backgroundColor: The background color of the HUD.
  ///   - interactiveHide: A Boolean value that determines whether the HUD should be hidden when a tap gesture is detected.
  ///   - animation: The animation to be used for showing and hiding the HUD.
  public init(
    backgroundColor: Color,
    interactiveHide: Bool,
    animation: Animation
  ) {
    self.defaultBackgroundColor = backgroundColor
    self.defaultInteractiveHide = interactiveHide
    self.defaultAnimation = animation
    self.currentAnimation = animation
    
    $contents
      .map { !$0.isEmpty }
      .removeDuplicates()
      .sink { [weak self] isNotEmpty in
        guard let self = self else { return }
        withAnimation(defaultAnimation) {
          self.isPresented = isNotEmpty
        }
      }
      .store(in: &bag)
  }
  
  /// Show a new HUD with the specified configurations.
  /// - Parameters:
  ///   - id: A unique identifier for the HUD content.
  ///   - animation: The animation to be used for showing this HUD content.
  ///   - transition: The transition to be used for this HUD content.
  ///   - backgroundColor: The background color for this HUD content.
  ///   - interactiveHide: A Boolean value that determines whether this HUD content should be hidden when a tap gesture is detected.
  ///   - content: The view to be displayed in this HUD content.
  public func show<ID: Hashable, C: View>(
    id: ID = UUID(),
    animation: Animation = .default,
    transition: AnyTransition = .opacity,
    alignment: Alignment = .center,
    ignoresSafeAreaEdges: Edge.Set = [],
    backgroundColor: Color? = nil,
    interactiveHide: Bool? = nil,
    content: () -> C
  ) {
    currentAnimation = animation
    contents.append(
      HudContent(
        id: id,
        content: AnyView(content().transition(transition)),
        animation: animation,
        transition: transition,
        alignment: alignment,
        ignoresSafeAreaEdges: ignoresSafeAreaEdges,
        interactiveHide: interactiveHide,
        backgroundColor: backgroundColor
      )
    )
  }
  
  /// Hide the HUD with the specified identifier.
  /// - Parameters:
  ///   - id: The unique identifier of the HUD content to be hidden.
  public func hide<ID: Hashable>(id: ID) {
    currentAnimation = contents.last?.animation ?? defaultAnimation
    contents.removeAll(where: { $0.id == AnyHashable(id) })
  }
  
  /// Hide all the contents in the HUD.
  public func hideAll() {
    currentAnimation = contents.count == 1
    ? contents.last!.animation
    : defaultAnimation
    contents.removeAll()
  }
}

/// The content to be displayed in a Heads-Up Display (HUD).
public struct HudContent<ID: Hashable, C: View> {
  let id: ID
  let content: C
  let animation: Animation
  let transition: AnyTransition
  let alignment: Alignment
  let ignoresSafeAreaEdges: Edge.Set
  let interactiveHide: Bool?
  let backgroundColor: Color?
}

public struct HudModifier: ViewModifier {
  @StateObject public var hud: Hud
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        hud.currentBackgroundColor
          .ignoresSafeArea()
          .opacity(hud.isPresented ? 1 : 0)
          .onTapGesture {
            if hud.currentInteractiveHide {
              hud.hideAll()
            }
          }
          .overlay {
            ForEach(hud.contents, id: \.id) {
              $0.content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: $0.alignment)
                .ignoresSafeArea(.all, edges: $0.ignoresSafeAreaEdges)
            }
          }
      }
      .animation(hud.currentAnimation, value: hud.contents.count)
      .environmentObject(hud)
  }
}
