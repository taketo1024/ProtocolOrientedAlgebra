import Foundation

public struct RationalNumber: Field {
    fileprivate let p, q: IntegerNumber

    public init(_ p: IntegerNumber, _ q: IntegerNumber) {
        guard q != 0 else {
            fatalError("Given 0 for the dominator of a RationalNumber")
        }

        let d = abs(gcd(p, q)) * (q / abs(q))
        if d == 1 {
            (self.p, self.q) = (p, q)
        } else {
            (self.p, self.q) = (p / d, q / d)
        }
    }

    public init(intValue n: IntegerNumber) {
        self.init(n, 1)
    }

    public init(_ n: IntegerNumber) {
        self.init(intValue: n)
    }

    public var inverse: RationalNumber? {
        return (p != 0) ? RationalNumber(q, p) : nil
    }

    public var numerator: IntegerNumber {
        return p
    }

    public var denominator: IntegerNumber {
        return q
    }

    public static func == (a: RationalNumber, b: RationalNumber) -> Bool {
        return a.p * b.q == a.q * b.p
    }

    public static func + (a: RationalNumber, b: RationalNumber) -> RationalNumber {
        return RationalNumber(a.p * b.q + a.q * b.p, a.q * b.q)
    }

    public static prefix func - (a: RationalNumber) -> RationalNumber {
        return RationalNumber(-a.p, a.q)
    }

    public static func - (a: RationalNumber, b: RationalNumber) -> RationalNumber {
        return RationalNumber(a.p * b.q - a.q * b.p, a.q * b.q)
    }

    public static func * (a: RationalNumber, b: RationalNumber) -> RationalNumber {
        return RationalNumber(a.p * b.p, a.q * b.q)
    }

    public static func / (a: RationalNumber, b: RationalNumber) -> RationalNumber {
        return RationalNumber(a.p * b.q, a.q * b.p)
    }

    public var description: String {
        switch q {
        case 1:  return "\(p)"
        default: return "\(p)/\(q)"
        }
    }

    public static var symbol: String {
        return "Q"
    }

    public var hashValue: Int {
        return (p.hashValue &* 31) &+ q.hashValue
    }
}
