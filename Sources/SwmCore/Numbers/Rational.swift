public typealias RationalNumber = Rational<Int>
public typealias 𝐐 = RationalNumber

public struct Rational<Base: EuclideanRing>: Field {
    public let numerator: Base
    public let denominator: Base  // memo: (p, q) coprime, q > 0.
    
    @inlinable
    public init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    @inlinable
    public init(_ n: Base) {
        self.init(reduced: n, .identity)
    }
    
    @inlinable
    public init(_ p: Base, _ q: Base) {
        guard !q.isZero else {
            fatalError("Given 0 for the dominator.")
        }
        
        let a = q.normalizingUnit
        if a.isIdentity {
            self.init(normalized: p, q)
        } else {
            self.init(normalized: p * a, q * a)
        }
    }

    @inlinable
    internal init(normalized p: Base, _ q: Base) {
        switch (p, q) {
        case (_, .identity):
            self.init(reduced: p, .identity)
        case (.zero, _):
            self.init(reduced: .zero, .identity)
        default:
            let d = gcd(p, q).normalized
            switch d {
            case .identity:
                self.init(reduced: p, q)
            default:
                self.init(reduced: p / d, q / d)
            }
        }
    }
    
    @inlinable
    internal init(reduced p: Base, _ q: Base) {
        self.numerator = p
        self.denominator = q
    }

    //    @inlinable
    //    public init(from r: 𝐐) {
    //        self.init(r.numerator, r.denominator)
    //    }
    
    @inlinable
    public var isZero: Bool {
        numerator.isZero
    }
    
    @inlinable
    public var isIdentity: Bool {
        numerator.isIdentity && denominator.isIdentity
    }
    
    @inlinable
    public var inverse: Self? {
        numerator.isZero ? nil : .init(reduced: denominator, numerator)
    }
    
    @inlinable
    @_specialize(where Base == Int)
    public static func + (a: Self, b: Self) -> Self {
        let p = a.numerator * b.denominator + a.denominator * b.numerator
        let q = a.denominator * b.denominator
        return .init(p, q)
    }
    
    @inlinable
    @_specialize(where Base == Int)
    public static prefix func - (a: Self) -> Self {
        .init(-a.numerator, a.denominator)
    }
    
    @inlinable
    @_specialize(where Base == Int)
    public static func * (a: Self, b: Self) -> Self {
        .init(a.numerator * b.numerator, a.denominator * b.denominator)
    }
    
    public var description: String {
        switch denominator {
        case .identity:  return "\(numerator)"
        default: return "\(numerator)/\(denominator)"
        }
    }
    
    public static var symbol: String {
        (Base.self == Int.self) ? "𝐐" : "Rational<\(Base.self)>"
    }
}

extension Rational: Comparable where Base: Comparable {
    @inlinable
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
}

extension Rational: Hashable where Base: Hashable {}

extension Rational: Codable where Base: Codable {}

extension Rational: ExpressibleByIntegerLiteral where Base: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(Base(integerLiteral: value))
    }
}

extension Rational: RealSubset, ComplexSubset, Randomable, RangeRandomable where Base == Int {
    @inlinable
    public var sign: Base {
        numerator.sign
    }
    
    @inlinable
    public var abs: Self {
        (numerator >= 0) == (denominator >= 0) ? self : -self
    }
    
    public var asReal: 𝐑 {
        .init(self)
    }
    
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
    
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
