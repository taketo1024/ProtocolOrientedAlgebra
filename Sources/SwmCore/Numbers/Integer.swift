import Foundation

public typealias 𝐙 = Int

extension 𝐙: EuclideanRing, Randomable {
    @inlinable
    public init(from n: 𝐙) {
        self.init(n)
    }

    @inlinable
    public static var zero: 𝐙 {
        0
    }

    @inlinable
    public var inverse: 𝐙? {
        (self.abs == 1) ? self : nil
    }

    @inlinable
    public var normalizingUnit: 𝐙 {
        (self >= 0) ? 1 : -1
    }

    @inlinable
    public var sign: 𝐙 {
        (self >  0) ? 1 :
        (self == 0) ? 0 :
                     -1
    }

    @inlinable
    public var abs: 𝐙 {
        (self >= 0) ? self : -self
    }

    @inlinable
    public var isEven: Bool {
        (self % 2 == 0)
    }

    @inlinable
    public var isOdd: Bool {
        (self % 2 == 1)
    }

    public func pow(_ n: 𝐙) -> 𝐙 {
        switch  self {
        case 1:
            return 1
        case -1:
            return n.isEven ? 1 : -1
        default:
            assert(n >= 0)
            return (0 ..< n).reduce(1){ (res, _) in self * res }
        }
    }

    @inlinable
    public var euclideanDegree: Int {
        Swift.abs(self)
    }
    
    @inlinable
    public static func /%(a: 𝐙, b: 𝐙) -> (quotient: 𝐙, remainder: 𝐙) {
        let q = a / b
        return (q, a - q * b)
    }
    
    @inlinable
    public static func ./(a: 𝐙, b: 𝐙) -> 𝐐 {
        .init(a, b)
    }
    
    public static var symbol: String {
        "𝐙"
    }
}

fileprivate var _primes: [𝐙] = []

extension 𝐙 {
    public var factorial: 𝐙 {
        let n = self
        if n < 0 {
            fatalError("factorial of negative number.")
        }
        return (n == 0) ? 1 : n * (n - 1).factorial
    }
    
    public var divisors: [𝐙] {
        if self.isZero {
            return []
        }
        
        var result: Set<𝐙> = []
        
        let a = self.abs
        let m = Int(sqrt(Double(a)))
        
        for d in 1...m {
            if d.divides(a) {
                result.insert(d)
                result.insert(a/d)
            }
        }
        
        return result.sorted()
    }

    public static func primes(upto n: 𝐙) -> [𝐙] {
        if let last = _primes.last, n <= last {
            return _primes.filter{ $0 <= n }
        }
        
        var result: [𝐙] = []
        var seive = _primes + Array( (_primes.last ?? 1) + 1 ... n.abs )
        
        while let a = seive.first {
            seive = seive.filter{ $0 % a > 0 }
            result.append(a)
        }
        
        _primes = result
        return result
    }
    
    public var primeFactors: [𝐙] {
        var result: [𝐙] = []
        var q = self
        
        let ps = 𝐙.primes(upto: self)
        for p in ps {
            while q % p == 0 {
                q /= p
                result.append(p)
            }
        }
        
        return result
    }
    
    public var partitions: [[Int]] {
        assert(self >= 0)
        if self == 0 {
            return [[]]
        } else {
            return self.partitions(lowerBound: 1)
        }
    }
    
    internal func partitions(lowerBound: Int) -> [[Int]] {
        let n = self
        if lowerBound > n {
            return []
        } else {
            return (lowerBound ... n).flatMap { i -> [[Int]] in
                let ps = (n - i).partitions(lowerBound: Swift.max(i, lowerBound))
                return ps.map { I in [i] + I }
            } + [[n]]
        }
    }
}

extension 𝐙: RealSubset {
    public var asReal: 𝐑 {
        .init(self)
    }
}

extension 𝐙: ComplexSubset {
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
}
