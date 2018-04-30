//
//  SymmetricPolynomials.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct SymmetricPolynomial<K: Field>: Subring, Submodule {
    public typealias Super = MPolynomial<K>
    public typealias CoeffRing = K

    private let p: MPolynomial<K>

    public init(_ p: MPolynomial<K>) {
        // TODO check symmetry
        self.p = p
    }

    public init(_ a: K) {
        self.init([IntList.empty : a])
    }

    public init(_ coeffs: [IntList : K]) {
        self.init( MPolynomial<K>(coeffs) )
    }

    public var asSuper: MPolynomial<K> {
        return p
    }

    public static func contains(_ g: MPolynomial<K>) -> Bool {
        fatalError("not implemented yet.")
    }

    // see: https://en.wikipedia.org/wiki/Symmetric_polynomial#Elementary_symmetric_polynomials
    public static func elementary(_ n: Int, _ i: Int) -> SymmetricPolynomial<K> {
        let mInds = n.choose(i).map { combi -> IntList in
            // e.g.  [0, 1, 3] -> (1, 1, 0, 1)
            let l = combi.last.flatMap{ $0 + 1 } ?? 0
            return IntList( (0 ..< l).map { combi.contains($0) ? 1 : 0 } )
        }

        let coeffs = Dictionary(pairs: mInds.map{ ($0, K.identity) } )
        return SymmetricPolynomial(MPolynomial(coeffs))
    }

    // see: https://en.wikipedia.org/wiki/Symmetric_polynomial#Monomial_symmetric_polynomials
    public static func monomial(_ n: Int, _ I: IntList) -> SymmetricPolynomial<K> {
        assert(n == I.total)
        let Js = Permutation.allPermutations(ofLength: n).map { s in
            I.permuted(by: s)
        }.unique()
        let elements = Dictionary( pairs: Js.map{ ($0, K.identity) } )
        return SymmetricPolynomial(MPolynomial(elements))
    }

    // returns the polynomial in elementary-symmetric-polynomials.
    // e.g. x^2 + xy + y^2 -> s_1^2 - s_2
    //
    // see: https://en.wikipedia.org/wiki/Elementary_symmetric_polynomial#The_fundamental_theorem_of_symmetric_polynomials

    public func elementaryDecomposition() -> MPolynomial<K> {
        var f = self
        var g = MPolynomial(f.constantTerm)

        let n = f.numberOfIndeterminates
        let s = SymmetricPolynomial<K>.elementary

        while f.maxDegree > 0 {
            let I = f.leadDegree
            let a = f.leadCoeff

            // If I = (i1, i2, ... ik),
            // then i1 >= i2 >= ... >= ik must hold.
            //
            // Let c = (i1 - i2, i2 - i3, ..., i{k-1} - ik, ik),
            // then p = s1^c1 * s2^c2 * ... * sk^ck  is a sym. poly. with leadDeg = i.

            let c = (0 ..< I.length).map{ j in (j < n) ? I[j] - I[j + 1] : I[j]  }
            let p = c.enumerated().map{ (j, cj) in s(n, j + 1).pow(cj) }.multiplyAll()

            f = f - a * p
            g = g + a * MPolynomial(IntList(c))

            assert(f.leadDegree < I)
        }

        return g
    }

    // Inheritences from Super

    internal var mIndices: [IntList] {
        return p.mIndices
    }
    public var numberOfIndeterminates: Int {
        return p.numberOfIndeterminates
    }
    public var maxDegree: Int {
        return p.maxDegree
    }
    public func coeff(_ indices: Int ...) -> K {
        return coeff(IntList(indices))
    }
    public func coeff(_ I: IntList) -> K {
        return p.coeff(I)
    }
    public var leadDegree: IntList {
        return p.leadDegree
    }
    public var leadCoeff: K {
        return p.leadCoeff
    }
    public var constantTerm: K {
        return p.constantTerm
    }
    public func map(_ f: ((K) -> K)) -> SymmetricPolynomial<K> {
        return SymmetricPolynomial(p.map(f))
    }
}
