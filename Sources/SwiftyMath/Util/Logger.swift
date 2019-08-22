//
//  Logger.swift
//  Sample
//
//  Created by Taketo Sano on 2019/08/22.
//

import Foundation

private var loggers: [Logger.Id : Logger] = [:]

public final class Logger {
    public struct Id: Hashable, CustomStringConvertible {
        private let id: String
        public init(_ id: String) {
            self.id = id
        }
        
        public var description: String {
            return id
        }
    }
    
    public enum Level: Int, Comparable, CustomStringConvertible {
        case info, warning, error
        public var description: String {
            switch self {
            case .info: return "info"
            case .warning: return "warning"
            case .error: return "error"
            }
        }
        
        public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public let id: Id
    public private(set) var isActive: Bool
    public var level: Level
    public var outputStream: TextOutputStream? = nil
    
    private init(_ id: Id) {
        self.id = id
        self.isActive = true
        self.level = .warning
    }
    
    public static func get(_ id: Id) -> Logger {
        if let logger = loggers[id] {
            return logger
        } else {
            let logger = Logger(id)
            loggers[id] = logger
            return logger
        }
    }
    
    public func activate() {
        self.isActive = true
    }
    
    public func deactivate() {
        self.isActive = false
    }
    
    public func log(level: Level = .info, _ msg: @autoclosure () -> String) {
        if isActive && level >= self.level {
            let str = "[\(id):\(level)] \(msg())"
            if outputStream != nil {
                outputStream!.write(str + "\n")
            } else {
                print(str)
            }
        }
    }
    
    public func info(_ msg: @autoclosure () -> String) {
        log(level: .info, msg())
    }
    
    public func warning(_ msg: @autoclosure () -> String) {
        log(level: .warning, msg())
    }
    
    public func error(_ msg: @autoclosure () -> String) {
        log(level: .error, msg())
    }
}
