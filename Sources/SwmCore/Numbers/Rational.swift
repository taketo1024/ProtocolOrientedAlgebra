public typealias 𝐐 = RationalNumber

public struct RationalNumber: FractionField {
    public typealias Base = Int
    public let numerator: Base
    public let denominator: Base  // memo: (p, q) coprime, q > 0.
    
    @inlinable
    public init(reduced p: Base, _ q: Base) {
        self.numerator = p
        self.denominator = q
    }
    
    @inlinable
    public var sign: Base {
        numerator.sign
    }
    
    @inlinable
    public var abs: Self {
        (numerator >= 0) == (denominator >= 0) ? self : -self
    }
    
    public static var symbol: String {
        "𝐐"
    }
}

extension RationalNumber: Comparable {}
extension RationalNumber: Hashable {}
extension RationalNumber: Codable {}
extension RationalNumber: ExpressibleByIntegerLiteral {}

extension RationalNumber: RealSubset {
    public var asReal: 𝐑 {
        .init(self)
    }
}

extension RationalNumber: ComplexSubset {
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
}

extension RationalNumber: RangeRandomable {
    public static func random() -> Self {
        .init(.random(), .random())
    }
    
    public static func random(in range: Range<Self>) -> Self {
        random(range.lowerBound, range.upperBound, closed: false)
    }
    
    public static func random(in range: ClosedRange<Self>) -> Self {
        random(range.lowerBound, range.upperBound, closed: true)
    }
    
    private static func random(_ x0: Self, _ x1: Self, closed: Bool) -> Self {
        let slice = Int.random(in: 1 ..< 100)
        let q = lcm(x0.denominator, x1.denominator) * slice
        let p0 = q * x0.numerator / x0.denominator
        let p1 = q * x1.numerator / x1.denominator
        let p = closed ? Int.random(in: p0 ... p1) : Int.random(in: p0 ..< p1)
        return .init(p, q)
    }
}
