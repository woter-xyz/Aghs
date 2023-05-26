//
//  HudManager.swift
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
  
  func hudManager(
    backgroundColor: Color = .black.opacity(0.5),
    interactiveHide: Bool = false,
    animation: Animation = .linear(duration: 0.1)
  ) -> some View {
    base.modifier(
      HudManagerModifier(hudManager: .init(
        backgroundColor: backgroundColor,
        interactiveHide: interactiveHide,
        animation: animation
      ))
    )
  }
}

public final class HudManager: ObservableObject {
  
  @Published public private(set) var isPresented = false
  
  @Published var contents: [HudContent<AnyHashable, AnyView>] = []
  
  private var defaultBackgroundColor: Color
  private var defaultInteractiveHide: Bool
  private var defaultAnimation: Animation
  private var bag = Set<AnyCancellable>()
  
  public init(
    backgroundColor: Color,
    interactiveHide: Bool,
    animation: Animation
  ) {
    self.defaultBackgroundColor = backgroundColor
    self.defaultInteractiveHide = interactiveHide
    self.defaultAnimation = animation
    
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
  
  public func show<ID: Hashable, C: View>(
    id: ID = UUID(),
    animation: Animation = .default,
    transition: AnyTransition = .opacity,
    backgroundColor: Color? = nil,
    interactiveHide: Bool? = nil,
    content: () -> C
  ) {
    contents.append(
      HudContent(
        id: id,
        content: AnyView(content().transition(transition)),
        animation: animation,
        transition: transition,
        interactiveHide: interactiveHide,
        backgroundColor: backgroundColor
      )
    )
  }
  
  public func hide<ID: Hashable>(id: ID) {
    contents.removeAll(where: { $0.id == AnyHashable(id) })
  }
  
  public func hideAll() {
    contents.removeAll()
  }
  
  var currentBackgroundColor: Color {
    contents.last?.backgroundColor ?? defaultBackgroundColor
  }
  
  var currentInteractiveHide: Bool {
    contents.last?.interactiveHide ?? defaultInteractiveHide
  }
  
  var currentAnimation: Animation {
    contents.last?.animation ?? defaultAnimation
  }
}

public struct HudContent<ID: Hashable, C: View> {
  let id: ID
  let content: C
  let animation: Animation
  let transition: AnyTransition
  let interactiveHide: Bool?
  let backgroundColor: Color?
}

public struct HudManagerModifier: ViewModifier {
  @StateObject public var hudManager: HudManager
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        hudManager.currentBackgroundColor
          .ignoresSafeArea()
          .opacity(hudManager.isPresented ? 1 : 0)
          .onTapGesture {
            if hudManager.currentInteractiveHide {
              hudManager.hideAll()
            }
          }
          .overlay {
            ForEach(hudManager.contents, id: \.id) {
              $0.content
            }
          }
      }
      .animation(hudManager.currentAnimation, value: hudManager.contents.count)
      .environmentObject(hudManager)
  }
}
