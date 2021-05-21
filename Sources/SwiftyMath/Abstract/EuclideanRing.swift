public protocol EuclideanRing: Ring {
    var  euclideanDegree: Int { get }
    func divides(_ a: Self) -> Bool
    func isDivible(by a: Self) -> Bool
    
    static func /% (a: Self, b: Self) -> (quotient: Self, remainder: Self)
    static func / (a: Self, b: Self) -> Self
    static func % (a: Self, b: Self) -> Self
}

public extension EuclideanRing {
    static func / (_ a: Self, b: Self) -> Self {
        (a /% b).quotient
    }
    
    static func % (_ a: Self, b: Self) -> Self {
        (a /% b).remainder
    }
    
    func divides(_ b: Self) -> Bool {
        b.isDivible(by: self)
    }
    
    func isDivible(by a: Self) -> Bool {
        let b = self
        return (a.isZero && b.isZero) || (!a.isZero && (b % a).isZero)
    }
    
    var matrixEliminationWeight: Int {
        euclideanDegree
    }
}

public func gcd<R: EuclideanRing>(_ a: R, _ b: R) -> R {
    b.isZero ? a : gcd(b, a % b)
}

public func lcm<R: EuclideanRing>(_ a: R, _ b: R) -> R {
    (a * b) / gcd(a, b)
}

public func extendedGcd<R: EuclideanRing>(_ a: R, _ b: R) -> (x: R, y: R, gcd: R) {
    typealias M = Matrix2x2<R>
    
    func euclid(_ a: R, _ b: R, _ qs: [R]) -> (qs: [R], r: R) {
        switch b {
        case .zero:
            return (qs, a)
        default:
            let (q, r) = a /% b
            return euclid(b, r, qs.appended(q))
        }
    }
    
    let (qs, r) = euclid(a, b, [])
    
    let m = qs.reversed().map { q -> M in
        [.zero, .identity,
         .identity, -q]
    }.multiplyAll()
    
    return (x: m[0, 0], y: m[0, 1], gcd: r)
}

public protocol EuclideanIdeal: Ideal where Super: EuclideanRing {
    static var generator: Super { get }
}

public extension EuclideanIdeal {
    static func contains(_ a: Super) -> Bool {
        a.isDivible(by: generator)
    }
    
    static var symbol: String {
        "(\(generator))"
    }
}

public protocol EuclideanQuotientRing: QuotientRing where Mod: EuclideanIdeal {
    static func reduce(_ a: Base) -> Base
}

public extension EuclideanQuotientRing {
    static var mod: Base {
        Mod.generator
    }
    
    static func reduce(_ a: Base) -> Base {
        a % mod
    }
    
    var inverse: Self? {
        // find: a * x + b * y = u  (u: unit)
        // then: a^-1 = u^-1 * x (mod b)
        let (x, _, u) = extendedGcd(representative, Self.mod)
        if let uInv = u.inverse {
            return Self(uInv * x)
        } else {
            return nil
        }
    }
}
