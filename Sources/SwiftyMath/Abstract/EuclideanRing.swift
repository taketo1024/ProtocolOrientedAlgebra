public protocol EuclideanRing: Ring {
    var  euclideanDegree: Int { get }
    func divides(_ a: Self) -> Bool
    func isDivible(by a: Self) -> Bool
    
    static func /% (a: Self, b: Self) -> (q: Self, r: Self)
    static func / (a: Self, b: Self) -> Self
    static func % (a: Self, b: Self) -> Self
}

public extension EuclideanRing {
    static func / (_ a: Self, b: Self) -> Self {
        (a /% b).q
    }
    
    static func % (_ a: Self, b: Self) -> Self {
        (a /% b).r
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
    static var mod: Super { get }
}

public extension EuclideanIdeal {
    static func contains(_ a: Super) -> Bool {
        a.isDivible(by: mod)
    }
    
    static func quotientRepresentative(of a: Super) -> Super {
        a % mod
    }
    
    static func quotientInverse(of a: Super) -> Super? {
        // find: a * x + b * y = u  (u: unit)
        // then: a^-1 = u^-1 * x (mod b)
        let (x, _, u) = extendedGcd(a, mod)
        if let uInv = u.inverse {
            return uInv * x
        } else {
            return nil
        }
    }
    
    static var symbol: String {
        "(\(mod))"
    }
}
