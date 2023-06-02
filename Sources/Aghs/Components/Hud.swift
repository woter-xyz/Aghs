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
  
  /// Initialize a global Hud with the specified configurations.
  ///
  /// ```swift
  /// @main
  /// struct Aghs_exampleApp: App {
  ///
  ///   var body: some Scene {
  ///     WindowGroup {
  ///       HomeView()
  ///         .ax.initHud()
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - backgroundColor: The background color of the Hud. Default value is black with opacity of 0.5.
  ///   - interactiveHide: A Boolean value that determines whether the Hud should be hidden when a tap gesture is detected. Default value is `false`.
  ///   - animation: The animation to be used for showing and hiding the Hud. Default value is linear animation with a duration of 0.1 seconds.
  /// - Returns: A `View` with the specified Hud configurations.
  @MainActor
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

/// A global Hud manager.
@MainActor
public final class Hud: ObservableObject {
  
  public var frame: CGRect = .zero
  @Published public private(set) var isPresented = false
  @Published var contents: [HudContent<AnyHashable, AnyView>] = []
  var currentAnimation: Animation
  var currentBackgroundColor: Color
  var currentInteractiveHide: Bool {
    contents.last?.interactiveHide ?? defaultInteractiveHide
  }
  
  private var defaultBackgroundColor: Color
  private var defaultInteractiveHide: Bool
  private var defaultAnimation: Animation
  private var bag = Set<AnyCancellable>()
  
  /// Initialize a new `Hud` with the specified configurations.
  /// - Parameters:
  ///   - backgroundColor: The background color of the Hud.
  ///   - interactiveHide: A Boolean value that determines whether the Hud should be hidden when a tap gesture is detected.
  ///   - animation: The animation to be used for showing and hiding the Hud.
  init(
    backgroundColor: Color,
    interactiveHide: Bool,
    animation: Animation
  ) {
    self.defaultBackgroundColor = backgroundColor
    self.defaultInteractiveHide = interactiveHide
    self.defaultAnimation = animation
    self.currentAnimation = animation
    self.currentBackgroundColor = backgroundColor
    
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
  
  /// Show a new Hud with the specified configurations.
  /// - Parameters:
  ///   - id: A unique identifier for the Hud content.
  ///   - animation: The animation to be used for showing this Hud content.
  ///   - transition: The transition to be used for this Hud content.
  ///   - alignment: The alignment to use for this Hud content within its parent. The default value is `.center`, which means the content will be centered in its parent.
  ///   - ignoresSafeAreaEdges: The edges along which the safe area insets should be ignored for this Hud content. The default value is an empty set, which means that the content observes all safe area insets.
  ///   - backgroundColor: The background color for this Hud content.
  ///   - interactiveHide: A Boolean value that determines whether this Hud content should be hidden when a tap gesture is detected.
  ///   - content: The view to be displayed in this Hud content.
  public func show<ID: Hashable, C: View>(
    id: ID = UUID(),
    animation: Animation = .default,
    transition: AnyTransition = .opacity.combined(with: .scale),
    alignment: Alignment = .center,
    ignoresSafeAreaEdges: Edge.Set = [],
    backgroundColor: Color? = nil,
    interactiveHide: Bool? = nil,
    content: () -> C
  ) {
    currentAnimation = animation
    currentBackgroundColor = backgroundColor ?? defaultBackgroundColor
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
  
  /// Hide the Hud with the specified identifier.
  /// - Parameters:
  ///   - id: The unique identifier of the hud content to be hidden.
  public func hide<ID: Hashable>(id: ID) {
    currentAnimation = contents.last?.animation ?? defaultAnimation
    contents.removeAll(where: { $0.id == AnyHashable(id) })
  }
  
  /// Hide all the contents in the Hud.
  public func hideAll() {
    currentAnimation = contents.count == 1
    ? contents.last!.animation
    : defaultAnimation
    contents.removeAll()
  }
}

/// The content to be displayed in a Hud.
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
          .ax.frameReader {
            hud.frame = $0
          }
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
          .animation(hud.currentAnimation, value: hud.contents.count)
      }
      .environmentObject(hud)
  }
}
