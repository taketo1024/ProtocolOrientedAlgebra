//
//  Homology.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/07.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// A class representing the total (co)Homology group for a given ChainComplex.
// Consists of the direct-sum of i-th Homology groups:
//
//   H = H_0 ⊕ H_1 ⊕ ... ⊕ H_n
//
// where each group is decomposed into invariant factors:
//
//   H_i = (R/(a_1) ⊕ ... ⊕ R/(a_t)) ⊕ (R ⊕ ... ⊕ R)
//

public typealias   Homology<A: FreeModuleBase, R: EuclideanRing> = _Homology<Descending, A, R>
public typealias Cohomology<A: FreeModuleBase, R: EuclideanRing> = _Homology<Ascending, A, R>

// TODO abstract as `GradedModule`
public final class _Homology<T: ChainType, A: FreeModuleBase, R: EuclideanRing>: AlgebraicStructure {
    public typealias Cycle = FreeModule<A, R>

    public let name: String
    public let topDegree: Int
    public let offset: Int

    private let chainComplex: _ChainComplex<T, A, R>?
    private var _summands: [Summand?]

    public init(_ chainComplex: _ChainComplex<T, A, R>) {
        self.name = chainComplex.name
        self.topDegree = chainComplex.topDegree
        self.offset = chainComplex.offset

        self.chainComplex = chainComplex
        self._summands = Array(repeating: nil, count: chainComplex.topDegree - chainComplex.offset + 1) // lazy init
    }

    // TODO
    public init(name: String, _ H: _Homology<T, A, R>, _ map: _ChainMap<T, A, A, R>, _ factorizer: @escaping (FreeModule<A, R>) -> [R]) {
        self.name = name
        self.topDegree = H.topDegree
        self.offset = H.offset

        self.chainComplex = nil
        self._summands = []

        self._summands = (0 ..< H._summands.count).map { i in
            let summand = H[i]
            let subSummands = summand.structure.summands.map{ ss in
                SimpleModuleStructure.Summand( map.appliedTo(ss.generator), ss.divisor )
            }
            let str = SimpleModuleStructure(subSummands, factorizer)
            return Summand(self, str)
        }
    }

    public subscript(i: Int) -> Summand {
        guard (offset ... topDegree).contains(i) else {
            return Summand.zero(self)
        }

        if let g = _summands[i - offset] {
            return g
        } else {
            let g = generateSummand(i)
            _summands[i - offset] = g
            return g
        }
    }

    public static func ==(a: _Homology<T, A, R>, b: _Homology<T, A, R>) -> Bool {
        return (a.offset == b.offset) && (a.topDegree == b.topDegree) && (a.offset ... a.topDegree).forAll { i in a[i] == b[i] }
    }

    public var description: String {
        return (T.descending ? "H" : "cH") + "(\(name); \(R.symbol))"
    }

    public var detailDescription: String {
        return (T.descending ? "H" : "cH") + "(\(name); \(R.symbol)) = {\n"
            + (offset ... topDegree).map{ i in (i, self[i]) }
                .map{ (i, g) in "\t\(i) : \(g.detailDescription)"}
                .joined(separator: ",\n")
            + "\n}"
    }

    private func generateSummand(_ i: Int) -> Summand {
        let C = chainComplex!
        let basis = C.chainBasis(i)
        let (A1, A2) = (C.boundaryMatrix(i), C.boundaryMatrix(T.descending ? i + 1 : i - 1))
        let (E1, E2) = (A1.eliminate(), A2.eliminate())

        let S = SimpleModuleStructure.invariantFactorDecomposition(
            generators:       basis,
            generatingMatrix: E1.kernelMatrix,
            relationMatrix:   E2.imageMatrix,
            transitionMatrix: E1.kernelTransitionMatrix
        )

        return Summand(self, S)
    }

    public class Summand: AlgebraicStructure {
        internal var homology: _Homology<T, A, R> // FIXME circular reference!
        public let structure: SimpleModuleStructure<A, R>

        internal init(_ H: _Homology<T, A, R>, _ structure: SimpleModuleStructure<A, R>) {
            self.homology = H
            self.structure = structure
        }

        internal static func zero(_ H: _Homology<T, A, R>) -> Summand {
            return Summand(H, SimpleModuleStructure.zeroModule)
        }

        public var isTrivial: Bool {
            return structure.isTrivial
        }

        public var isFree: Bool {
            return structure.isFree
        }

        public var rank: Int {
            return structure.rank
        }

        public var summands: [SimpleModuleStructure<A, R>.Summand] {
            return structure.summands
        }

        public func generator(_ i: Int) -> _HomologyClass<T, A, R> {
            return _HomologyClass(structure.generator(i), homology)
        }

        public var generators: [_HomologyClass<T, A, R>] {
            return (0 ..< summands.count).map{ i in generator(i) }
        }

        public func torsion(_ i: Int) -> R {
            return structure.torsion(i)
        }

        public var zero: _HomologyClass<T, A, R> {
            return _HomologyClass.zero
        }

        public func factorize(_ z: Cycle) -> [R] {
            return structure.factorize(z)
        }

        public func cycleIsNullHomologous(_ z: Cycle) -> Bool {
            return structure.elementIsZero(z)
        }

        public func cyclesAreHomologous(_ z1: Cycle, _ z2: Cycle) -> Bool {
            return cycleIsNullHomologous(z1 - z2)
        }

        public static func ==(lhs: _Homology<T, A, R>.Summand, rhs: _Homology<T, A, R>.Summand) -> Bool {
            return lhs.structure == rhs.structure
        }

        public var description: String {
            return structure.description
        }

        public var detailDescription: String {
            return structure.detailDescription
        }
    }
}

public extension Homology where T == Descending {
    public func bettiNumer(i: Int) -> Int {
        return self[i].rank
    }

    public var eulerNumber: Int {
        return (0 ... topDegree).reduce(0){ $0 + (-1).pow($1) * bettiNumer(i: $1) }
    }
}
