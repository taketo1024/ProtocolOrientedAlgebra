import Foundation

public typealias 𝐙 = Int

extension 𝐙: EuclideanRing {
    public init(from n: 𝐙) {
        self.init(n)
    }

    public var normalizeUnit: 𝐙 {
        return (self > 0) ? 1 : -1
    }

    public var degree: Int {
        return Swift.abs(self)
    }

    public var abs: 𝐙 {
        return Swift.abs(self)
    }

    public var inverse: 𝐙? {
        return (self.abs == 1) ? self : nil
    }

    public var isEven: Bool {
        return (self % 2 == 0)
    }

    public var sign: 𝐙 {
        return isEven ? 1 : -1
    }

    public static func eucDiv(_ a: 𝐙, _ b: 𝐙) -> (q: 𝐙, r: 𝐙) {
        let q = a / b
        return (q: q, r: a - q * b)
    }

    public static var symbol: String {
        return "𝐙"
    }

    // TODO remove `**`
    public func pow(_ n: 𝐙) -> 𝐙 {
        assert(n >= 0)
        switch  self {
        case 1:
            return 1
        case -1:
            return n.isEven ? 1 : -1
        default:
            return (0 ..< n).reduce(1){ (res, _) in res * self }
        }
    }
}

public struct IntegerIdeal<n: _Int>: EuclideanIdeal {
    public typealias Super = 𝐙

    public static var generator: 𝐙 {
        return n.intValue
    }

    public let a: 𝐙

    public init(_ a: 𝐙) {
        self.a = a
    }

    public var asSuper: 𝐙 {
        return a
    }
}

public struct IntegerQuotientRing<n: _Int>: _QuotientRing, FiniteSetType {
    public typealias Sub = IntegerIdeal<n>

    private let a: Base

    public init(_ a: Base) {
        self.a = Sub.reduced(a)
    }

    public var representative: 𝐙 {
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

    public var representative: 𝐙 {
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
