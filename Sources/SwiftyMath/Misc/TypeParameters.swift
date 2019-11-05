public protocol SizeType {
    static var intValue: Int { get }
    static var isDynamic: Bool { get }
}

public protocol StaticSizeType: SizeType {}
public extension StaticSizeType {
    static var isDynamic: Bool { return false }
}

public struct _0 : StaticSizeType { public static let intValue = 0 }
public struct _1 : StaticSizeType { public static let intValue = 1 }
public struct _2 : StaticSizeType { public static let intValue = 2 }
public struct _3 : StaticSizeType { public static let intValue = 3 }
public struct _4 : StaticSizeType { public static let intValue = 4 }
public struct _5 : StaticSizeType { public static let intValue = 5 }
public struct _6 : StaticSizeType { public static let intValue = 6 }
public struct _7 : StaticSizeType { public static let intValue = 7 }
public struct _8 : StaticSizeType { public static let intValue = 8 }
public struct _9 : StaticSizeType { public static let intValue = 9 }
// add more if necessary

public protocol PrimeSizeType: StaticSizeType {}
extension _2: PrimeSizeType {}
extension _3: PrimeSizeType {}
extension _5: PrimeSizeType {}
extension _7: PrimeSizeType {}
// add more if necessary

public struct DynamicSize : SizeType {
    public static var intValue: Int { fatalError() }
    public static var isDynamic: Bool { return true }
}
