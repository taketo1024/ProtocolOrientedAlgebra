
public protocol PolynomialType {
    static var isNormal: Bool { get }
}
public struct NormalPolynomialType : PolynomialType { public static var isNormal = true  }
public struct LaurentPolynomialType: PolynomialType { public static var isNormal = false }

public typealias        Polynomial<R: Ring> = _Polynomial<NormalPolynomialType , R>
public typealias LaurentPolynomial<R: Ring> = _Polynomial<LaurentPolynomialType, R>

public struct _Polynomial<T: PolynomialType, R: Ring>: Ring, Module {
    public typealias CoeffRing = R
    
    // MEMO: We may put `symbol` as a type parameter,
    // but creating a struct for each symbol would be a nuisance.
    public let symbol: String
    
    internal let coeffs: [Int : R]
    
    public init(from n: 𝐙) {
        let a = R(from: n)
        self.init(a)
    }
    
    public init(_ a: R) {
        self.init(coeffs: [0 : a])
    }
    
    public init(symbol: String = "x", coeffs: [Int : R]) {
        assert( !(T.isNormal && coeffs.contains{ (i, a) in i < 0 && a != .zero } ) )
        self.symbol = symbol
        self.coeffs = coeffs.filter{ (_, a) in a != .zero }
    }
    
    public init(symbol: String = "x", lowerDegree: Int = 0, coeffs: [R]) {
        let dict = Dictionary(pairs: coeffs.enumerated().map{ (i, a) in (i + lowerDegree, a) })
        self.init(symbol: symbol, coeffs: dict)
    }
    
    public init(symbol: String = "x", lowerDegree: Int = 0, coeffs: R...) {
        self.init(symbol: symbol, lowerDegree: lowerDegree, coeffs: coeffs)
    }
    
    public init(symbol: String = "x", degreeRange: CountableClosedRange<Int>, gen: ((Int) -> R)) {
        self.init(symbol: symbol, lowerDegree: degreeRange.lowerBound, coeffs: degreeRange.map(gen))
    }
    
    public static func indeterminate(symbol: String) -> _Polynomial<T, R> {
        return _Polynomial(symbol: symbol, coeffs: [1: .identity])
    }
    
    public static var indeterminate: _Polynomial<T, R> {
        return indeterminate(symbol: "x")
    }
    
    public var lowerDegree: Int {
        return coeffs.keys.min() ?? 0
    }
    
    public var upperDegree: Int {
        return coeffs.keys.max() ?? 0
    }
    
    public var degree: Int {
        return upperDegree
    }
    
    public func coeff(_ i: Int) -> R {
        return coeffs[i, default: .zero]
    }
    
    public var leadCoeff: R {
        return coeff(degree)
    }
    
    public var leadTerm: _Polynomial<T, R> {
        return _Polynomial(coeffs: [degree: leadCoeff])
    }
    
    public var isMonic: Bool {
        return leadCoeff == .identity
    }
    
    public var isConst: Bool {
        return (upperDegree, lowerDegree) == (0, 0)
    }
    
    public var constTerm: R {
        return coeff(0)
    }
    
    public func mapCoeffs(_ f: ((R) -> R)) -> _Polynomial<T, R> {
        return _Polynomial(symbol: symbol, coeffs: coeffs.mapValues(f))
    }
    
    public func withSymbol(_ symbol: String) -> _Polynomial<T, R> {
        return _Polynomial(symbol: symbol, coeffs: coeffs)
    }
    
    public var normalizeUnit: _Polynomial<T, R> {
        if let a = leadCoeff.inverse {
            return _Polynomial(symbol: symbol, coeffs: a)
        } else {
            return _Polynomial(symbol: symbol, coeffs: .identity)
        }
    }
    
    public var inverse: _Polynomial<T, R>? {
        if T.isNormal, degree == 0, let a = constTerm.inverse {
            return _Polynomial(symbol: symbol, coeffs: a)
        } else if !T.isNormal, lowerDegree == upperDegree, let a = leadCoeff.inverse {
            return _Polynomial(symbol: symbol, coeffs: [-degree : a])
        }
        return nil
    }
    
    public var derivative: _Polynomial<T, R> {
        return _Polynomial(symbol: symbol, coeffs: coeffs.mapPairs { (i, a) -> (Int, R) in
            (i - 1, R(from: i) * a)
        })
    }
    
    // Horner's method
    // see: https://en.wikipedia.org/wiki/Horner%27s_method
    public func evaluate(_ x: R) -> R {
        let A = x.pow(lowerDegree)
        let B = (lowerDegree ..< upperDegree).reversed().reduce(leadCoeff) { (res, i) in
            coeff(i) + x * res
        }
        return A * B
    }

    // MEMO: more generally, this could be done with any superring of K.
    public func evaluate<n>(_ x: SquareMatrix<n, R>) -> SquareMatrix<n, R> {
        typealias M = SquareMatrix<n, R>
        let A = x.pow(lowerDegree)
        let B = (lowerDegree ..< upperDegree).reversed().reduce(leadCoeff * M.identity) { (res, i) -> M in
            M(scalar: coeff(i)) + x * res
        }
        return A * B
    }
    
    public static func == (f: _Polynomial<T, R>, g: _Polynomial<T, R>) -> Bool {
        return (f.isConst && g.isConst || f.symbol == g.symbol) && f.coeffs == g.coeffs
    }
    
    public static func + (f: _Polynomial<T, R>, g: _Polynomial<T, R>) -> _Polynomial<T, R> {
        assert(f.isConst || g.isConst || f.symbol == g.symbol)
        let symbol = f.isConst ? g.symbol : f.symbol
        
        let degs = Set(f.coeffs.keys).union(g.coeffs.keys)
        let coeffs = Dictionary(keys: degs) { i in
            f.coeff(i) + g.coeff(i)
        }
        return _Polynomial(symbol: symbol, coeffs: coeffs)
    }
    
    public static prefix func - (f: _Polynomial<T, R>) -> _Polynomial<T, R> {
        return f.mapCoeffs { -$0 }
    }
    
    public static func * (f: _Polynomial<T, R>, g: _Polynomial<T, R>) -> _Polynomial<T, R> {
        assert(f.isConst || g.isConst || f.symbol == g.symbol)
        let symbol = f.isConst ? g.symbol : f.symbol
        
        let kRange = (f.lowerDegree + g.lowerDegree ... f.upperDegree + g.upperDegree)
        let coeffs = kRange.map { k -> (Int, R) in
            let iRange = max(f.lowerDegree, k - g.upperDegree) ... min(k - g.lowerDegree, f.upperDegree)
            let a = iRange.sum { i -> R in
                f.coeff(i) * g.coeff(k - i)
            }
            return (k, a)
        }
        return _Polynomial(symbol: symbol, coeffs: Dictionary(pairs: coeffs))
    }
    
    public static func * (r: R, f: _Polynomial<T, R>) -> _Polynomial<T, R> {
        return f.mapCoeffs { r * $0 }
    }
    
    public static func * (f: _Polynomial<T, R>, r: R) -> _Polynomial<T, R> {
        return f.mapCoeffs { $0 * r }
    }
    
    public var description: String {
        return Format.terms("+", coeffs.keys.sorted().map{ i in (coeff(i), symbol, i)} )
    }
    
    public static var symbol: String {
        return T.isNormal ? "\(R.symbol)[x]" : "\(R.symbol)[x, x⁻¹]"
    }
    
    public var hashValue: Int {
        return leadCoeff.hashValue
    }
}

public extension _Polynomial where R: Field {
    public func toMonic() -> _Polynomial<T, R> {
        let a = leadCoeff
        return self.mapCoeffs{ $0 / a }
    }
}

extension _Polynomial: EuclideanRing where T == NormalPolynomialType, R: Field {
    public func eucDiv(by g: _Polynomial<T, R>) -> (q: _Polynomial<T, R>, r: _Polynomial<T, R>) {
        typealias A = _Polynomial<T, R>
        
        let f = self
        if g == .zero {
            fatalError("divide by 0")
        }
        
        func eucDivMonomial(_ f: A, _ g: A) -> (q: A, r: A) {
            let n = f.degree - g.degree
            
            if n < 0 {
                return (.zero, f)
            } else {
                let x = A.indeterminate(symbol: symbol)
                let a = f.leadCoeff / g.leadCoeff
                let q = a * x.pow(n)
                let r = f - q * g
                return (q, r)
            }
        }
        
        return (0 ... max(0, f.degree - g.degree))
            .reversed()
            .reduce( (.zero, f) ) { (result: (A, A), degree: Int) in
                let (q, r) = result
                let m = eucDivMonomial(r, g)
                return (q + m.q, m.r)
        }
    }
}
