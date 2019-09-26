public protocol EuclideanRing: Ring {
    var  eucDegree: Int { get }
    func eucDiv(by b: Self) -> (q: Self, r: Self) // override point
    func divides(_ a: Self) -> Bool
    func isDivible(by a: Self) -> Bool

    static func /% (a: Self, b: Self) -> (q: Self, r: Self)
    static func / (a: Self, b: Self) -> Self
    static func % (a: Self, b: Self) -> Self
}

public extension EuclideanRing {
    static func /% (_ a: Self, b: Self) -> (q: Self, r: Self) {
        a.eucDiv(by: b)
    }
    
    static func / (_ a: Self, b: Self) -> Self {
        a.eucDiv(by: b).q
    }
    
    static func % (_ a: Self, b: Self) -> Self {
        a.eucDiv(by: b).r
    }
    
    func divides(_ b: Self) -> Bool {
        b.isDivible(by: self)
    }
    
    func isDivible(by a: Self) -> Bool {
        let b = self
        return (a.isZero && b.isZero) || (!a.isZero && (b % a).isZero)
    }
}

public func gcd<R: EuclideanRing>(_ a: R, _ b: R) -> R {
    b.isZero ? a : gcd(b, a % b)
}

public func lcm<R: EuclideanRing>(_ a: R, _ b: R) -> R {
    (a * b) / gcd(a, b)
}

public func bezout<R: EuclideanRing>(_ a: R, _ b: R) -> (x: R, y: R, r: R) {
    typealias M = SquareMatrix<_2, R>
    
    func euclid(_ a: R, _ b: R, _ qs: [R]) -> (qs: [R], r: R) {
        switch b {
        case .zero:
            return (qs, a)
        default:
            let (q, r) = a /% b
            return euclid(b, r, [q] + qs)
        }
    }
    
    let (qs, r) = euclid(a, b, [])
    
    let m = qs.reduce(M.identity) { (m: M, q: R) -> M in
        m * M(.zero, .identity, .identity, -q)
    }
    
    return (x: m[0, 0], y: m[0, 1], r: r)
}

public protocol EuclideanIdeal: Ideal where Super: EuclideanRing {
    static var mod: Super { get }
}

public extension EuclideanIdeal {
    static func normalizedInQuotient(_ a: Super) -> Super {
        a % mod
    }
    
    static func contains(_ a: Super) -> Bool {
        a.isDivible(by: mod)
    }
    
    static func inverseInQuotient(_ r: Super) -> Super? {
        // find: a * r + b * m = u (u: unit)
        // then: r^-1 = u^-1 * a (mod m)
        let (a, _, u) = bezout(r, mod)
        return u.inverse.map{ inv in inv * a }
    }
    
    static var symbol: String {
        "(\(mod))"
    }
}
