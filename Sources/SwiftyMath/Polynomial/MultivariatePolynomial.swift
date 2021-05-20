//
//  MultivariatePolynomial.swift
//  
//
//  Created by Taketo Sano on 2021/05/19.
//

public protocol MultivariatePolynomialIndeterminates: GenericPolynomialIndeterminate where Exponent == MultiIndex<NumberOfIndeterminates> {
    associatedtype NumberOfIndeterminates: SizeType
    static var isFinite: Bool { get }
    static var numberOfIndeterminates: Int { get }
    static func symbolOfIndeterminate(at i: Int) -> String
    static func degreeOfIndeterminate(at i: Int) -> Int
}

extension MultivariatePolynomialIndeterminates {
    public static var isFinite: Bool {
        !NumberOfIndeterminates.isDynamic
    }
    
    public static var numberOfIndeterminates: Int {
        NumberOfIndeterminates.intValue
    }
    
    public static func degreeOfIndeterminate(at i: Int) -> Int {
        1
    }
    
    public static func degreeOfMonomial(withExponent e: Exponent) -> Int {
        assert(!isFinite || e.length <= numberOfIndeterminates)
        return e.indices.enumerated().sum { (i, k) in
            k * degreeOfIndeterminate(at: i)
        }
    }
    
    public static func descriptionOfMonomial(withExponent e: Exponent) -> String {
        let s = e.indices.enumerated().map{ (i, d) in
            (d > 0) ? Format.power(symbolOfIndeterminate(at: i), d) : ""
        }.joined()
        return s.isEmpty ? "1" : s
    }
}

public protocol MultivariatePolynomialType: GenericPolynomialType where Indeterminate: MultivariatePolynomialIndeterminates {
    typealias NumberOfIndeterminates = Indeterminate.NumberOfIndeterminates
}

extension MultivariatePolynomialType {
    public static func indeterminate(_ i: Int) -> Self {
        let l = Indeterminate.isFinite ? Indeterminate.numberOfIndeterminates : i + 1
        let indices = (0 ..< l).map{ $0 == i ? 1 : 0 }
        let I = MultiIndex<NumberOfIndeterminates>(indices)
        return .init(coeffs: [I : .identity] )
    }
    
    public static var numberOfIndeterminates: Int {
        NumberOfIndeterminates.intValue
    }
    
    public static func monomial(withExponents I: Exponent) -> Self {
        .init(coeffs: [I: .identity])
    }
    
    public func coeff(_ exponent: Int...) -> BaseRing {
        self.coeff(Exponent(exponent))
    }
    
    public func evaluate(by values: [BaseRing]) -> BaseRing {
        assert(!Indeterminate.isFinite || values.count <= Self.numberOfIndeterminates)
        return coeffs.sum { (I, a) in
            a * I.indices.enumerated().multiply{ (i, e) in values.count < i ? .zero : values[i].pow(e) }
        }
    }
    
    public func evaluate(by values: BaseRing...) -> BaseRing {
        evaluate(by: values)
    }
    
//    public static func elementarySymmetric(_ i: Int) -> Self {
//        assert(xn.isFinite)
//        assert(i >= 0)
//
//        let n = xn.numberOfIndeterminates
//        if i > n {
//            return .zero
//        }
//
//        let exponents = (0 ..< n).choose(i).map { combi -> [Int] in
//            // e.g.  [0, 1, 3] -> (1, 1, 0, 1)
//            let l = combi.last ?? 0
//            return (0 ... l).map { combi.contains($0) ? 1 : 0 }
//        }
//
//        let coeffs = Dictionary(pairs: exponents.map{ ($0, R.identity) } )
//        return .init(coeffs: coeffs)
//    }
//    
//    public static var symbol: String {
//        typealias xn = Indeterminates
//        if xn.isFinite {
//            let n = xn.numberOfIndeterminates
//            return "\(BaseRing.symbol)[\( (0 ..< n).map{ i in xn.symbol(i) }.joined(separator: ", "))]"
//        } else {
//            return "\(BaseRing.symbol)[\( (0 ..< 3).map{ i in xn.symbol(i) }.appended("…").joined(separator: ", "))]"
//        }
//    }
}

public struct MultivariatePolynomial<R: Ring, xn: MultivariatePolynomialIndeterminates>: MultivariatePolynomialType {
    public typealias BaseRing = R
    public typealias Indeterminate = xn

    public let coeffs: [Exponent : R]
    public init(coeffs: [Exponent : R]) {
        self.coeffs = coeffs.exclude{ $0.value.isZero }
    }
    
    public var inverse: Self? {
        (isConst && constCoeff.isInvertible)
            ? .init(constCoeff.inverse!)
            : nil
    }
    
    public static func monomials<S: Sequence>(ofDegree deg: Int, usingIndeterminates indices: S) -> [Self] where S.Element == Int {
        assert(indices.isUnique)
        assert(indices.allSatisfy{ $0 >= 0 })
        assert(
            deg == 0 && indices.allSatisfy{ i in Indeterminate.degreeOfIndeterminate(at: i) != 0 } ||
            deg  > 0 && indices.allSatisfy{ i in Indeterminate.degreeOfIndeterminate(at: i) >  0 } ||
            deg  < 0 && indices.allSatisfy{ i in Indeterminate.degreeOfIndeterminate(at: i) <  0 }
        )
        
        typealias E = Indeterminate.Exponent // MultiIndex<n>
        func generate(_ deg: Int, _ indices: ArraySlice<Int>) -> [[Int]] {
            if indices.isEmpty {
                return deg == 0 ? [[]] : []
            }
            
            let i = indices.last!
            let d = Indeterminate.degreeOfIndeterminate(at: i)
            let c = deg / d  // = 0 when |deg| < |d|
            
            return (0 ... c).flatMap { e -> [[Int]] in
                generate(deg - e * d, indices.dropLast()).map { res in
                    res + [e]
                }
            }
        }
        
        let max = indices.max() ?? 0
        return generate(deg, ArraySlice(indices)).map { list -> Self in
            let table = Dictionary(pairs: zip(indices, list))
            let exponent = (0 ... max).map { i in
                table[i] ?? 0
            }
            return monomial(withExponents: Exponent(exponent))
        }
    }
}

extension MultivariatePolynomial where Indeterminate.NumberOfIndeterminates: StaticSizeType {
    public static func monomials(ofDegree deg: Int) -> [Self] {
        monomials(ofDegree: deg, usingIndeterminates: 0 ..< numberOfIndeterminates)
    }
}

extension MultivariatePolynomial: ExpressibleByIntegerLiteral where R: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: R.IntegerLiteralType) {
        self.init(BaseRing(integerLiteral: value))
    }
}
