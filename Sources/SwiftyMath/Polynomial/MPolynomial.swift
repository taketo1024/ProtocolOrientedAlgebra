//
//  MPolynomial.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct MPolynomial<K: Field>: Ring, Module {
    public typealias CoeffRing = K

    // e.g. [(2, 1, 3) : 5] -> 5 * x^2 * y * z^3
    private let coeffs: [IntList : K]

    public init(from n: 𝐙) {
        self.init(K(from: n))
    }

    public init(_ a: K) {
        self.init([IntList.empty : a])
    }

    public init(_ I: IntList) {
        self.init([I : .identity])
    }

    public init(_ elements: ([Int], K) ...) {
        let coeffs = Dictionary(pairs: elements.map{ (I, a) in (IntList(I), a) } )
        self.init(coeffs)
    }

    public init(_ coeffs: [IntList : K]) {
        self.coeffs = coeffs.filter{ $0.value != .zero }
    }

    public static var zero: MPolynomial<K> {
        return MPolynomial([:])
    }

    public var inverse: MPolynomial<K>? {
        return (maxDegree == 0) ? coeff(.empty).inverse.flatMap{ a in MPolynomial(a) } : nil
    }

    internal var mIndices: [IntList] {
        return coeffs.keys.sorted()
    }

    public var numberOfIndeterminates: Int {
        return coeffs.keys.reduce(0){ max($0, $1.length) }
    }

    public var maxDegree: Int {
        return coeffs.keys.reduce(0) { max($0, $1.total) }
    }

    public func coeff(_ indices: Int ...) -> K {
        return coeff(IntList(indices))
    }

    public func coeff(_ I: IntList) -> K {
        return coeffs[I] ?? .zero
    }

    public var leadDegree: IntList {
        return mIndices.last ?? .empty
    }

    public var leadCoeff: K {
        return self.coeff(leadDegree)
    }

    public var constantTerm: K {
        return self.coeff(.empty)
    }

    public func map(_ f: ((K) -> K)) -> MPolynomial<K> {
        return MPolynomial( coeffs.mapValues(f) )
    }

    public static func == (f: MPolynomial<K>, g: MPolynomial<K>) -> Bool {
        return (f.mIndices == g.mIndices) &&
            f.mIndices.forAll { I in f.coeff(I) == g.coeff(I) }
    }

    public static func + (f: MPolynomial<K>, g: MPolynomial<K>) -> MPolynomial<K> {
        var coeffs = f.coeffs
        for (I, a) in g.coeffs {
            coeffs[I] = coeffs[I, default: .zero] + a
        }
        return MPolynomial(coeffs)
    }

    public static prefix func - (f: MPolynomial<K>) -> MPolynomial<K> {
        return f.map { -$0 }
    }

    public static func * (f: MPolynomial<K>, g: MPolynomial<K>) -> MPolynomial<K> {
        var coeffs = [IntList : K]()
        for (I, J) in f.mIndices.allCombinations(with: g.mIndices) {
            let K = I * J
            coeffs[K] = coeffs[K, default: .zero] + f.coeff(I) * g.coeff(J)
        }
        return MPolynomial(coeffs)
    }

    public static func * (r: K, f: MPolynomial<K>) -> MPolynomial<K> {
        return f.map { r * $0 }
    }

    public static func * (f: MPolynomial<K>, r: K) -> MPolynomial<K> {
        return f.map { $0 * r }
    }

    public var description: String {
        func toTerm(_ I: IntList) -> String {
            return I.elements.enumerated().compactMap { (i, n) -> String? in
                if n > 0 {
                    return (n > 1) ? "x\(Format.sub(i+1))\(Format.sup(n))" : "x\(Format.sub(i+1))"
                } else {
                    return nil
                }
            }.joined()
        }

        let res = mIndices.reversed().map { i -> String in
            let a = self.coeff(i)
            let x = toTerm(i)
            switch a {
            case  .identity: return x
            case -.identity: return "-\(x)"
            default: return "\(a)\(x)"
            }
        }.joined(separator: " + ")

        return res.isEmpty ? "0" : res
    }

    public static var symbol: String {
        return "\(K.symbol)[x₁ … ]"
    }

    public var hashValue: Int {
        return leadCoeff.hashValue
    }
}

