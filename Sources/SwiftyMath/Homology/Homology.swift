//
//  Homology.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/07.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

// A class representing the total (co)Homology group for a given ChainComplex.
// Consists of the direct-sum of i-th Homology groups:
//
//   H = H_0 ⊕ H_1 ⊕ ... ⊕ H_n
//
// where each group is decomposed into invariant factors:
//
//   H_i = (R/(a_1) ⊕ ... ⊕ R/(a_t)) ⊕ (R ⊕ ... ⊕ R)
//

public typealias   Homology<A: BasisElementType, R: EuclideanRing> = _Homology<Descending, A, R>
public typealias Cohomology<A: BasisElementType, R: EuclideanRing> = _Homology<Ascending, A, R>

// TODO abstract as `GradedModule`
public final class _Homology<T: ChainType, A: BasisElementType, R: EuclideanRing>: AlgebraicStructure {
    public typealias Cycle = FreeModule<A, R>
    public typealias Summand = SimpleModuleStructure<A, R>

    public let name: String
    public let offset: Int
    public var topDegree: Int

    private var _summands: [Summand?]
    private var _generator: (Int) -> Summand

    public init(name: String? = nil, chainComplex: _ChainComplex<T, A, R>) {
        self.name = name ?? "\(T.descending ? "H" : "cH")(\(chainComplex.name))"
        self.offset = chainComplex.offset
        self.topDegree = chainComplex.topDegree

        self._summands = Array(repeating: nil, count: chainComplex.topDegree - chainComplex.offset + 1) // lazy init
        self._generator = { i in
            let basis = chainComplex.chainBasis(i)
            let (Ain, Aout) = (chainComplex.boundaryMatrix(i - T.degree), chainComplex.boundaryMatrix(i))
            let (Ein, Eout) = (Ain.elimination(), Aout.elimination())

            let (Z, B, ZT) = (Eout.kernelMatrix, Ein.imageMatrix, Eout.kernelTransitionMatrix)

            return SimpleModuleStructure(
                basis:            basis,
                generatingMatrix: Z,
                relationMatrix:   B,
                transitionMatrix: ZT
            )
        }
    }

    internal init(name: String, offset: Int, topDegree: Int, summands: [Summand]) {
        self.name = name
        self.offset = offset
        self.topDegree = topDegree
        self._summands = summands
        self._generator = {_ in fatalError()}
    }

    public subscript(i: Int) -> Summand {
        guard (offset ... topDegree).contains(i) else {
            return Summand.zeroModule
        }

        if let g = _summands[i - offset] {
            return g
        } else {
            let g = _generator(i)
            _summands[i - offset] = g
            return g
        }
    }

    public func bettiNumer(_ i: Int) -> Int {
        return self[i].rank
    }

    public var eulerCharacteristic: Int {
        return (offset ... topDegree).sum{ i in (-1).pow(i) * bettiNumer(i) }
    }

    public var gradedEulerCharacteristic: LaurentPolynomial<R> {
        let q = LaurentPolynomial<R>.indeterminate
        return (offset ... topDegree).sum { i -> LaurentPolynomial<R> in
            R(from: (-1).pow(i)) * self[i].summands.sum { s -> LaurentPolynomial<R> in
                s.isFree ? q.pow(s.generator.degree) : .zero
            }
        }
    }

    public func homologyClass(_ z: Cycle) -> _HomologyClass<T, A, R> {
        return _HomologyClass(z, self)
    }

    public static func ==(a: _Homology<T, A, R>, b: _Homology<T, A, R>) -> Bool {
        return (a.offset == b.offset) && (a.topDegree == b.topDegree) && (a.offset ... a.topDegree).forAll { i in a[i] == b[i] }
    }

    public var description: String {
        return name
    }

    public var detailDescription: String {
        return name + " = {\n"
            + (offset ... topDegree).map{ i in (i, self[i]) }
                .map{ (i, g) in "\t\(i) : \(g.detailDescription)"}
                .joined(separator: ",\n")
            + "\n}"
    }
}

extension _Homology: Codable where A: Codable, R: Codable {
    enum CodingKeys: String, CodingKey {
        case name, offset, topDegree, summands
    }

    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let name = try c.decode(String.self, forKey: .name)
        let offset = try c.decode(Int.self, forKey: .offset)
        let topDegree = try c.decode(Int.self, forKey: .topDegree)
        let summands = try c.decode([Summand].self, forKey: .summands)
        self.init(name: name, offset: offset, topDegree: topDegree, summands: summands)
    }

    public func encode(to encoder: Encoder) throws {
        let summands = (offset ... topDegree).map { i in self[i] }
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(offset, forKey: .offset)
        try c.encode(topDegree, forKey: .topDegree)
        try c.encode(summands, forKey: .summands)
    }
}
