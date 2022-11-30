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
  var content: AnyView = AnyView(EmptyView())
  var background: AnyView = AnyView(Color.black.opacity(0.6))
  var presentationMode: PresentationMode = .forever()
  
  public init() {}
  
  public func show(
    background: some View = AnyView(Color.black.opacity(0.6)),
    presentationMode: PresentationMode = .forever(),
    content: () -> some View
  ) {
    self.background = AnyView(background)
    self.presentationMode = presentationMode
    self.content = AnyView(content())
    withAnimation {
      isPresented = true
    }
  }
  
  public enum PresentationMode {
    case forever(interactiveHide: Bool = true)
    case dimissAfter(seconds: Double = 2.0)
  }
}

public extension Aghs.Bag {
  
  struct HudModifier: ViewModifier {
    @StateObject public var hud: Hud
    
    public func body(content: Content) -> some View {
      ZStack {
        content
        
        if hud.isPresented {
          hud.background
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
              hud.isPresented = false
            }
          
          hud.content
            .transition(.opacity.combined(with: .scale))
        }
      }
      .environmentObject(hud)
    }
  }
}
