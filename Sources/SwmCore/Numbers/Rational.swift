public typealias 𝐐 = RationalNumber

public struct RationalNumber: Field, ExpressibleByIntegerLiteral, Comparable, Hashable, Codable {
    public let numerator:   𝐙
    public let denominator: 𝐙  // memo: (p, q) coprime, q > 0.
    
    @inlinable
    public init(from n: 𝐙) {
        self.init(n, 1)
    }
    
    @inlinable
    public init(from r: 𝐐) {
        self.init(r.numerator, r.denominator)
    }
    
    @inlinable
    public init(_ n: 𝐙) {
        self.init(from: n)
    }
    
    public init(_ p_: 𝐙, _ q_: 𝐙) {
        guard q_ != 0 else {
            fatalError("Given 0 for the dominator.")
        }
        
        let (p, q) = (q_ > 0) ? (p_, q_) : (-p_, -q_)
        
        switch (p, q) {
        case (_, 1):
            (self.numerator, self.denominator) = (p, 1)
        case (0, _):
            (self.numerator, self.denominator) = (0, 1)
        case (1, _):
            (self.numerator, self.denominator) = (1, q)
        case (-1, _):
            (self.numerator, self.denominator) = (-1, q)
        default:
            let d = gcd(p, q).abs
            switch d {
            case 1:
                (self.numerator, self.denominator) = (p, q)
            default:
                (self.numerator, self.denominator) = (p/d, q/d)
            }
        }
    }
    
    @inlinable
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    
    @inlinable
    public var sign: 𝐙 {
        numerator.sign
    }
    
    @inlinable
    public var abs: 𝐐 {
        (numerator >= 0) == (denominator >= 0) ? self : -self
    }
    
    @inlinable
    public var inverse: 𝐐? {
        (numerator != 0) ? 𝐐(denominator, numerator) : nil
    }
    
    @inlinable
    public static func + (a: 𝐐, b: 𝐐) -> 𝐐 {
        .init(a.numerator * b.denominator + a.denominator * b.numerator, a.denominator * b.denominator)
    }
    
    @inlinable
    public static prefix func - (a: 𝐐) -> 𝐐 {
        .init(-a.numerator, a.denominator)
    }
    
    @inlinable
    public static func * (a: 𝐐, b: 𝐐) -> 𝐐 {
        .init(a.numerator * b.numerator, a.denominator * b.denominator)
    }
    
    @inlinable
    public static func <(lhs: 𝐐, rhs: 𝐐) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
    
    public var computationalWeight: Double {
        isZero ? 0 : Double(max(numerator.abs, denominator))
    }
    
    public var description: String {
        switch denominator {
        case 1:  return "\(numerator)"
        default: return "\(numerator)/\(denominator)"
        }
    }
    
    public static var symbol: String {
        "𝐐"
    }
}

extension 𝐐: Randomable {
    private static func random(_ x0: 𝐐, _ x1: 𝐐, closed: Bool) -> 𝐐 {
        let slice = 10
        let q = lcm(x0.denominator, x1.denominator) * slice
        let p0 = q * x0.numerator / x0.denominator
        let p1 = q * x1.numerator / x1.denominator
        let p = closed ? 𝐙.random(in: p0 ... p1) : 𝐙.random(in: p0 ..< p1)
        return .init(p, q)
    }
    
    public static func random(in range: Range<𝐐>) -> 𝐐 {
        random(range.lowerBound, range.upperBound, closed: false)
    }
    
    public static func random(in range: ClosedRange<𝐐>) -> 𝐐 {
        random(range.lowerBound, range.upperBound, closed: true)
    }
}

extension 𝐐: RealSubset {
    public var asReal: 𝐑 {
        .init(self)
    }
}

extension 𝐐: ComplexSubset {
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
}
