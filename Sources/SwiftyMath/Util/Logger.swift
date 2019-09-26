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
    public var level: Level
    
    public private(set) var handlers: [FileHandle]
    public weak var bypass: Logger? = nil
    
    private let dateFormatter: DateFormatter
    
    private init(_ id: Id) {
        self.id = id
        self.level = .warning
        self.handlers = [FileHandle.standardOutput]
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
    
    public func addHandler(_ handler: FileHandle) {
        handlers.append(handler)
    }
    
    public func removeHandler(_ handler: FileHandle) {
        handlers.remove(element: handler)
    }
    
    public func log(level: Level = .info, _ msg: @autoclosure () -> String) {
        if level >= self.level {
            let label = "\(id)\( level > .info ? ":\(level)" : "" )"
            let date = dateFormatter.string(from: Date())
            let str = "\(date) [\(label)] \(msg())\n"
            write(str)
        }
    }
    
    private func write(_ str: String) {
        if let bypass = bypass {
            bypass.write(str)
        } else {
            let data = str.data(using: .utf8)!
            for hdl in handlers {
                hdl.write(data)
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
    
    @discardableResult
    public func measure(_ label: String? = nil, _ block: () throws -> Void) rethrows -> Double {
        let precision = 3.0
        let dec = pow(10.0, precision)
        
        let aLabel = label ?? "measure"
        log("start: \(aLabel)")
        
        let date = Date()
        
        try block()
        
        let time = -date.timeIntervalSinceNow
        let timeStr = (time < 1)
            ? "\(round(time * dec * 1000) / dec) msec."
            : "\(round(time * dec) / dec) sec."
        
        log("end:   \(aLabel), \(timeStr)")
        
        return time
    }

    public func newLine(_ count: Int = 1) {
        let str = String(repeating: "\n", count: count)
        write(str)
    }
    
    public func newSection() {
        let str = "\n------------------------------\n"
        write(str)
    }
}
