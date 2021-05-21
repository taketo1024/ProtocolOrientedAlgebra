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
        NumberOfIndeterminates.isFixed
    }
    
    public static var numberOfIndeterminates: Int {
        NumberOfIndeterminates.intValue
    }
    
    public static func degreeOfIndeterminate(at i: Int) -> Int {
        1
    }
    
    public static func degreeOfMonomial(withExponent e: Exponent) -> Int {
        assert(!isFinite || Exponent.length <= numberOfIndeterminates)
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

public struct BivariatePolynomialIndeterminates<x: PolynomialIndeterminate, y: PolynomialIndeterminate>: MultivariatePolynomialIndeterminates {
    public typealias NumberOfIndeterminates = _2
    public static func degreeOfIndeterminate(at i: Int) -> Int {
        switch i {
        case 0: return x.degree
        case 1: return y.degree
        default: fatalError()
        }
    }
    public static func symbolOfIndeterminate(at i: Int) -> String {
        switch i {
        case 0: return x.symbol
        case 1: return y.symbol
        default: fatalError()
        }
    }
}

public struct EnumeratedPolynomialIndeterminates<x: PolynomialIndeterminate, n: SizeType>: MultivariatePolynomialIndeterminates {
    public typealias NumberOfIndeterminates = n
    public static func degreeOfIndeterminate(at i: Int) -> Int {
        x.degree
    }
    public static func symbolOfIndeterminate(at i: Int) -> String {
        "\(x.symbol)\(Format.sub(i))"
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
        return .init(elements: [I : .identity] )
    }
    
    public static var numberOfIndeterminates: Int {
        NumberOfIndeterminates.intValue
    }
    
    public static func monomial(withExponents I: Exponent) -> Self {
        .init(elements: [I: .identity])
    }
    
    public func coeff(_ exponent: Int...) -> BaseRing {
        self.coeff(Exponent(exponent))
    }
    
    public func evaluate(by values: [BaseRing]) -> BaseRing {
        assert(!Indeterminate.isFinite || values.count <= Self.numberOfIndeterminates)
        return elements.sum { (I, a) in
            a * I.indices.enumerated().multiply{ (i, e) in values.count < i ? .zero : values[i].pow(e) }
        }
    }
    
    public func evaluate(by values: BaseRing...) -> BaseRing {
        evaluate(by: values)
    }
}

public struct MultivariatePolynomial<R: Ring, xn: MultivariatePolynomialIndeterminates>: MultivariatePolynomialType {
    public typealias BaseRing = R
    public typealias Indeterminate = xn

    public let elements: [Exponent : R]
    public init(elements: [Exponent : R]) {
        self.elements = elements.exclude{ $0.value.isZero }
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
    
    public static func elementarySymmetricPolynomial<S: Sequence>(ofDegree deg: Int, usingIndeterminates indices: S) -> Self where S.Element == Int {
        assert(indices.isUnique)
        assert(indices.allSatisfy{ $0 >= 0 })

        let n = indices.count
        if deg > n {
            return .zero
        }
        
        let max = indices.max() ?? 0
        let table = indices.asDictionary.inverse!
        
        let exponents = (0 ..< n).choose(deg).map { list -> [Int] in
            // e.g. [0, 1, 3] -> (1, 1, 0, 1)
            let set = Set(list)
            return (0 ... max).map { i in
                set.contains(table[i] ?? -1) ? 1 : 0
            }
        }
        
        return .init(elements: Dictionary(pairs: exponents.map{ (Exponent($0), .identity) } ))
    }
}

extension MultivariatePolynomial where Indeterminate.NumberOfIndeterminates: FixedSizeType {
    public static func monomials(ofDegree deg: Int) -> [Self] {
        monomials(ofDegree: deg, usingIndeterminates: 0 ..< numberOfIndeterminates)
    }
    
    public static func elementarySymmetricPolynomial(ofDegree deg: Int) -> Self {
        elementarySymmetricPolynomial(ofDegree: deg, usingIndeterminates: 0 ..< numberOfIndeterminates)
    }
}

extension MultivariatePolynomial: ExpressibleByIntegerLiteral where R: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: R.IntegerLiteralType) {
        self.init(BaseRing(integerLiteral: value))
    }
}
