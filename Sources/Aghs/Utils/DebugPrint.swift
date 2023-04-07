//
//  DebugPrint.swift
//  
//
//  Created by zzzwco on 2022/11/11.
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

public extension Aghs {
  
  /// Print messages in debug mode with file, method, line number, and a custom log type.
  ///
  /// - Parameters:
  ///   - message: The message to log. Supports variadic input.
  ///   - type: A `LogType` to classify the log message (default is .info).
  ///   - file: The name of the file where the log function is called (default is the current file name).
  ///   - method: The name of the method where the log function is called (default is the current method name).
  ///   - line: The line number where the log function is called (default is the current line number).
  static func print<T>(
    _ message: T...,
    type: Aghs.Bag.LogType = .info,
    file: String = #file,
    method: String = #function,
    line: Int = #line
  ) {
    #if DEBUG
    let message = message.map { "\($0)\n" }.joined()
    let content = "\(Date()), \((file as NSString).lastPathComponent)[\(line)], \(method): \n\(message)\n"
    Swift.print("\(type.rawValue) \(content)")
    #endif
  }
}

public extension Aghs.Bag {
  
  /// Enum that represents log message types with corresponding symbols and labels.
  enum LogType: String {
    case info = "🍺 [INFO]:"
    case warning = "⚠️ [WARNING]:"
    case error = "❌ [ERROR]:"
    case success = "✅ [SUCCESS]:"
  }
}
