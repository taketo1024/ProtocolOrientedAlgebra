public protocol SizeType {
    static var isFixed: Bool { get }
    static var intValue: Int { get }
}

extension SizeType {
    static var isArbitrary: Bool { !isFixed }
}

public struct anySize : SizeType {
    public static var isFixed: Bool { false }
    public static var intValue: Int { Int.max }
}

public protocol FixedSizeType: SizeType {}
public extension FixedSizeType {
    static var isFixed: Bool { true }
}

public struct _0 : FixedSizeType { public static let intValue = 0 }
public struct _1 : FixedSizeType { public static let intValue = 1 }
public struct _2 : FixedSizeType { public static let intValue = 2 }
public struct _3 : FixedSizeType { public static let intValue = 3 }
public struct _4 : FixedSizeType { public static let intValue = 4 }
public struct _5 : FixedSizeType { public static let intValue = 5 }
public struct _6 : FixedSizeType { public static let intValue = 6 }
public struct _7 : FixedSizeType { public static let intValue = 7 }
public struct _8 : FixedSizeType { public static let intValue = 8 }
public struct _9 : FixedSizeType { public static let intValue = 9 }
// add more if necessary

public protocol PrimeSizeType: FixedSizeType {}
extension _2: PrimeSizeType {}
extension _3: PrimeSizeType {}
extension _5: PrimeSizeType {}
extension _7: PrimeSizeType {}
// add more if necessary
