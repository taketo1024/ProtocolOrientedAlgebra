public typealias 𝐐 = RationalNumber

public struct RationalNumber: Field, Comparable, Hashable, Codable {
    internal let p, q: 𝐙  // memo: (p, q) coprime, q > 0.
    
    public init(from n: 𝐙) {
        self.init(n, 1)
    }
    
    public init(from r: 𝐐) {
        self.init(r.p, r.q)
    }
    
    public init(_ n: 𝐙) {
        self.init(from: n)
    }
    
    public init(_ p: 𝐙, _ q: 𝐙) {
        guard q != 0 else {
            fatalError("Given 0 for the dominator of a 𝐐")
        }
        
        let d = gcd(p, q).abs
        
        if d == 1 && q > 0 {
            (self.p, self.q) = (p, q)
        } else {
            let D = d * q.sign
            (self.p, self.q) = (p / D, q / D)
        }
    }
    
    public var sign: 𝐙 {
        p.sign
    }
    
    public var abs: 𝐐 {
        (p >= 0) == (q >= 0) ? self : -self
    }
    
    public var inverse: 𝐐? {
        (p != 0) ? 𝐐(q, p) : nil
    }
    
    public var numerator: 𝐙 {
        p
    }
    
    public var denominator: 𝐙 {
        q
    }
    
    public static func + (a: 𝐐, b: 𝐐) -> 𝐐 {
        .init(a.p * b.q + a.q * b.p, a.q * b.q)
    }
    
    public static prefix func - (a: 𝐐) -> 𝐐 {
        .init(-a.p, a.q)
    }
    
    public static func * (a: 𝐐, b: 𝐐) -> 𝐐 {
        .init(a.p * b.p, a.q * b.q)
    }
    
    public static func <(lhs: 𝐐, rhs: 𝐐) -> Bool {
        lhs.p * rhs.q < rhs.p * lhs.q
    }
    
    public var description: String {
        switch q {
        case 1:  return "\(p)"
        default: return "\(p)/\(q)"
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

extension 𝐙 {
    public static func ./(a: 𝐙, b: 𝐙) -> 𝐐 {
        .init(a, b)
    }
}
