import Foundation

public typealias 𝐑 = RealNumber

public struct RealNumber: Subfield, NormedSpace, Comparable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias Super = 𝐂
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double

    internal let value: Double
    public let error: Double

    public init(integerLiteral n: Int) {
        self.init(n)
    }

    public init(floatLiteral x: Double) {
        self.init(x)
    }

    public init(from x: 𝐙) {
        self.init(x)
    }

    public init(from r: 𝐐) {
        self.init(r)
    }

    public init(_ x: Int) {
        self.init(Double(x))
    }

    public init(_ r: 𝐐) {
        self.init(Double(r.p) / Double(r.q))
    }

    public init(_ value: Double) {
        self.init(value, value.ulp)
    }

    private init(_ value: Double, _ error: Double) {
        self.value = value
        self.error = error
    }

    public init(_ z: 𝐂) {
        assert(𝐑.contains(z))
        self.init(z.realPart.value)
    }

    public var sign: 𝐙 {
        return (value >  0) ? 1 :
               (value == 0) ? 0 :
                             -1
    }

    public var abs: 𝐑 {
        return 𝐑(Swift.abs(value))
    }

    public var norm: 𝐑 {
        return abs
    }

    public var inverse: 𝐑? {
        // 1/(x + e) ~ 1/x - (1/x^2)e + ...
        return (value != 0) ? 𝐑(1/value, error / (value * value)) : nil
    }

    public static func ==(a: 𝐑, b: 𝐑) -> Bool {
//        print(fabs(a.value - b.value), "<=", max(a.error, b.error), ":", fabs(a.value - b.value) < max(a.error, b.error))
        return fabs(a.value - b.value) <= max(a.error, b.error)
    }

    public static func +(a: 𝐑, b: 𝐑) -> 𝐑 {
        return 𝐑(a.value + b.value, a.error + b.error)
    }

    public static prefix func -(a: 𝐑) -> 𝐑 {
        return 𝐑(-a.value, a.error)
    }

    public static func *(a: 𝐑, b: 𝐑) -> 𝐑 {
        return 𝐑(a.value * b.value, a.error * fabs(b.value) + b.error * fabs(a.value))
    }

    public static func <(lhs: 𝐑, rhs: 𝐑) -> Bool {
        return lhs.value < rhs.value
    }

    public var sqrt: 𝐑 {
        return 𝐑(value.squareRoot())
    }

    public static prefix func √(x: 𝐑) -> 𝐑 {
        return x.sqrt
    }

    public var asDouble: Double {
        return value
    }

    public var asSuper: 𝐂 {
        return 𝐂(self, .zero)
    }

    public static func contains(_ z: 𝐂) -> Bool {
        return z.imaginaryPart == .zero
    }

    public var hashValue: Int {
        return value.hashValue
    }

    public var description: String {
        let res = value.description
        return res.hasSuffix(".0") ? String(res.dropLast(2)) : res
    }

    public static var symbol: String {
        return "𝐑"
    }
}

public let π = 𝐑(Double.pi)

public func exp(_ x: 𝐑) -> 𝐑 {
    return 𝐑(exp(x.value))
}

public func sin(_ x: 𝐑) -> 𝐑 {
    return 𝐑(sin(x.value))
}

public func cos(_ x: 𝐑) -> 𝐑 {
    return 𝐑(cos(x.value))
}

public func tan(_ x: 𝐑) -> 𝐑 {
    return 𝐑(tan(x.value))
}

public func asin(_ x: 𝐑) -> 𝐑 {
    return 𝐑(asin(x.value))
}

public func acos(_ x: 𝐑) -> 𝐑 {
    return 𝐑(acos(x.value))
}

public func atan(_ x: 𝐑) -> 𝐑 {
    return 𝐑(atan(x.value))
}
