import Foundation

public typealias IntegerNumber = Int

extension IntegerNumber: EuclideanRing {
    public init(intValue n: IntegerNumber) {
        self.init(n)
    }
    
    public var normalizeUnit: IntegerNumber {
        return (self > 0) ? 1 : -1
    }
    
    public var degree: Int {
        return abs(self)
    }
    
    public var inverse: IntegerNumber? {
        return (abs(self) == 1) ? self : nil
    }
    
    public static func eucDiv(_ a: IntegerNumber, _ b: IntegerNumber) -> (q: IntegerNumber, r: IntegerNumber) {
        let q = a / b
        return (q: q, r: a - q * b)
    }
    
    public static var symbol: String {
        return "Z"
    }
    
    // TODO remove `**`
    public func pow(_ n: IntegerNumber) -> IntegerNumber {
        assert(n >= 0)
        switch  self {
        case 1:
            return 1
        case -1:
            return (n % 2 == 0) ? 1 : -1
        default:
            return (0 ..< n).reduce(1){ (res, _) in res * self }
        }
    }
    
    public var evenOddSign: Int {
        return (self % 2 == 0) ? 1 : -1
    }
}

public struct IntegerIdeal<n: _Int>: EuclideanIdeal {
    public typealias Super = IntegerNumber
    
    public static var generator: IntegerNumber {
        return n.intValue
    }
    
    public let a: IntegerNumber
    
    public init(_ a: IntegerNumber) {
        self.a = a
    }
    
    public var asSuper: IntegerNumber {
        return a
    }
}

public struct IntegerQuotientRing<n: _Int>: _QuotientRing, FiniteSetType {
    public typealias Sub = IntegerIdeal<n>
    
    private let a: Base
    
    public init(_ a: Base) {
        self.a = Sub.reduced(a)
    }
    
    public var representative: IntegerNumber {
        return a
    }
    
    public static var allElements: [IntegerQuotientRing<n>] {
        return (0 ..< n.intValue).map{ IntegerQuotientRing($0) }
    }
    
    public static var countElements: Int {
        return n.intValue
    }
    
    public static var symbol: String {
        return "\(Base.symbol)/\(n.intValue)"
    }
}

// TODO merge with IntegerQuotientRing after conditional conformance is supported.
public struct IntegerQuotientField<n: _Prime>: Field, _QuotientRing, FiniteSetType {
    public typealias Sub = IntegerIdeal<n>
    
    private let a: Base
    
    public init(_ a: Base) {
        self.a = Sub.reduced(a)
    }
    
    public var representative: IntegerNumber {
        return a
    }
    
    public static var allElements: [IntegerQuotientField<n>] {
        return (0 ..< n.intValue).map{ IntegerQuotientField($0) }
    }
    
    public static var countElements: Int {
        return n.intValue
    }
    
    public static var symbol: String {
        return "\(Base.symbol)/\(n.intValue)"
    }
}
