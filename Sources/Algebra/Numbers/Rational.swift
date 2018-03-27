import Foundation

public typealias 𝐐 = RationalNumber

public struct RationalNumber: Field, Comparable {
    internal let p, q: 𝐙

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

        let d = gcd(p, q).abs * q.sign
        if d == 1 {
            (self.p, self.q) = (p, q)
        } else {
            (self.p, self.q) = (p / d, q / d)
        }
    }

    public var abs: 𝐐 {
        return (p >= 0) == (q >= 0) ? self : -self
    }

    public var inverse: 𝐐? {
        return (p != 0) ? 𝐐(q, p) : nil
    }

    public var numerator: 𝐙 {
        return p
    }

    public var denominator: 𝐙 {
        return q
    }

    public static func == (a: 𝐐, b: 𝐐) -> Bool {
        return a.p * b.q == a.q * b.p
    }

    public static func + (a: 𝐐, b: 𝐐) -> 𝐐 {
        return 𝐐(a.p * b.q + a.q * b.p, a.q * b.q)
    }

    public static prefix func - (a: 𝐐) -> 𝐐 {
        return 𝐐(-a.p, a.q)
    }

    public static func - (a: 𝐐, b: 𝐐) -> 𝐐 {
        return 𝐐(a.p * b.q - a.q * b.p, a.q * b.q)
    }

    public static func * (a: 𝐐, b: 𝐐) -> 𝐐 {
        return 𝐐(a.p * b.p, a.q * b.q)
    }

    public static func / (a: 𝐐, b: 𝐐) -> 𝐐 {
        return 𝐐(a.p * b.q, a.q * b.p)
    }

    public static func <(lhs: 𝐐, rhs: 𝐐) -> Bool {
        return lhs.p * rhs.q < rhs.p * lhs.q
    }

    public var description: String {
        switch q {
        case 1:  return "\(p)"
        default: return "\(p)/\(q)"
        }
    }

    public static var symbol: String {
        return "𝐐"
    }

    public var hashValue: Int {
        return (p.hashValue &* 31) &+ q.hashValue
    }
}
