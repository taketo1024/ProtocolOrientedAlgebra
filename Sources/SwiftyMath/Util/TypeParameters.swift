import Foundation

public protocol _Int {
    static var intValue: Int { get }
    static var isDynamic: Bool { get }
}

public extension _Int {
    static var isDynamic: Bool { return false }
}

public protocol _Prime: _Int {}

public struct _0 : _Int   { public static let intValue = 0 }
public struct _1 : _Int   { public static let intValue = 1 }
public struct _2 : _Prime { public static let intValue = 2 }
public struct _3 : _Prime { public static let intValue = 3 }
public struct _4 : _Int   { public static let intValue = 4 }
public struct _5 : _Prime { public static let intValue = 5 }
public struct _6 : _Int   { public static let intValue = 6 }
public struct _7 : _Prime { public static let intValue = 7 }
public struct _8 : _Int   { public static let intValue = 8 }
public struct _9 : _Int   { public static let intValue = 9 }

public struct Dynamic : _Int {
    public static var intValue: Int { fatalError() }
    public static var isDynamic: Bool { return true }
}
