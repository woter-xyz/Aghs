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
  
  func hudManager(_ hudManager: HudManager) -> some View {
    return base.modifier(HudManagerModifier(hudManager: hudManager))
  }
}

public final class HudManager: ObservableObject {
  
  @Published public var isPresented = false
  
  public var overlay: AnyView = AnyView(Color.black.opacity(0.5))
  
  var contents: [AnyView] = []
  var bag = Set<AnyCancellable>()
  
  public init() {
    $isPresented
      .sink { [weak self] output in
        guard let self else { return }
        if !output {
          contents.removeAll()
        }
      }
      .store(in: &bag)
  }
  
  public func show<C: View>(_ content: C) {
    contents.append(AnyView(content))
    isPresented = true
  }
}

public struct HudManagerModifier: ViewModifier {
  @StateObject public var hudManager: HudManager
  
  public func body(content: Content) -> some View {
    content
      .overlay {
        hudManager.overlay
          .ignoresSafeArea()
          .opacity(hudManager.isPresented ? 1 : 0)
          .onTapGesture {
            withAnimation(.linear(duration: 0.1)) {
              hudManager.isPresented = false
            }
          }
          .overlay {
            ForEach(0..<hudManager.contents.count, id: \.self) {
              hudManager.contents[$0]
            }
          }
      }
      .environmentObject(hudManager)
  }
}
