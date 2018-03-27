//
//  ModuleDecomposition.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/06.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// A decomposed form of a freely & finitely presented module,
// i.e. a module with finite generators and a finite & free presentation.
//
//           B        A
// 0 -> R^m ---> R^n ---> M -> 0
//
// ==> M ~= R^r + (R/d_0) + ... + (R/d_k),
//     r: rank, k: torsion
//
// See: https://en.wikipedia.org/wiki/Free_presentation
//      https://en.wikipedia.org/wiki/Structure_theorem_for_finitely_generated_modules_over_a_principal_ideal_domain#Invariant_factor_decomposition

public final class SimpleModuleStructure<A: FreeModuleBase, R: EuclideanRing>: ModuleStructure<R> {
    public  let summands: [Summand]
    private let factorizer: (FreeModule<A, R>) -> [R]

    public convenience init(_ summands: [Summand]) {
        self.init(summands, {_ in fatalError()})
    }

    public init(_ summands: [Summand], _ factorizer: @escaping (FreeModule<A, R>) -> [R]) {
        self.summands = summands
        self.factorizer = factorizer
        super.init()
    }

    public subscript(i: Int) -> Summand {
        return summands[i]
    }

    public static var zeroModule: SimpleModuleStructure<A, R> {
        return SimpleModuleStructure([], {_ in []})
    }

    public var isTrivial: Bool {
        return summands.isEmpty
    }

    public var isFree: Bool {
        return summands.forAll { $0.isFree }
    }

    public var rank: Int {
        return summands.filter{ $0.isFree }.count
    }

    public var generators: [FreeModule<A, R>] {
        return summands.map{ $0.generator }
    }

    public func generator(_ i: Int) -> FreeModule<A, R> {
        return summands[i].generator
    }

    public func torsion(_ i: Int) -> R {
        return summands[i].divisor
    }

    public var torsions: [R] {
        return summands.filter{ !$0.isFree }.map{ $0.divisor }
    }

    public func factorize(_ z: FreeModule<A, R>) -> [R] {
        return factorizer(z)
    }

    public func elementIsZero(_ z: FreeModule<A, R>) -> Bool {
        return factorize(z).forAll{ $0 == 0 }
    }

    public func elementsAreEqual(_ z1: FreeModule<A, R>, _ z2: FreeModule<A, R>) -> Bool {
        return elementIsZero(z1 - z2)
    }

    public static func ==(a: SimpleModuleStructure<A, R>, b: SimpleModuleStructure<A, R>) -> Bool {
        return a.summands == b.summands
    }

    public override var description: String {
        return summands.isEmpty ? "0" : summands.map{$0.description}.joined(separator: "⊕")
    }

    public var detailDescription: String {
        return "\(self),\t\(generators)"
    }

    public var asAbstract: AbstractSimpleModuleStructure<R> {
        let torsions = summands.filter{!$0.isFree}.map{$0.divisor}
        return AbstractSimpleModuleStructure(rank: rank, torsions: torsions)
    }

    public final class Summand: AlgebraicStructure {
        public let generator: FreeModule<A, R>
        public let divisor: R

        internal init(_ generator: FreeModule<A, R>, _ divisor: R) {
            self.generator = generator
            self.divisor = divisor
        }

        internal convenience init(_ a: A, _ divisor: R) {
            self.init(FreeModule(a), divisor)
        }

        public var isFree: Bool {
            return divisor == .zero
        }

        public static func ==(a: Summand, b: Summand) -> Bool {
            return (a.generator, a.divisor) == (b.generator, b.divisor)
        }

        public var description: String {
            switch isFree {
            case true : return R.symbol
            case false: return "\(R.symbol)/\(divisor)"
            }
        }
    }
}

public extension SimpleModuleStructure {
    public static func invariantFactorDecomposition(generators: [A], generatingMatrix A: ComputationalMatrix<R>, relationMatrix B: ComputationalMatrix<R>, transitionMatrix T: ComputationalMatrix<R>) -> SimpleModuleStructure<A, R> {

        assert(A.rows == B.rows)
        assert(A.rows >= A.cols)  // n ≧ k
        assert(A.cols >= B.cols)  // k ≧ l

        let (k, l) = (A.cols, B.cols)

        // R ∈ M(k, l) : Relation from A to B,  B = A * R.
        //
        // R = T * B, since
        //     T * A = I_k,
        //     T * B = T * (A * R) = I_k * R = R.
        //
        // R gives the structure of the quotient A / B.

        let R1 = T * B

        // Retake bases of Z and B to obtain the decomposition of H.
        //
        //   P' * R * Q' = [D'; O].
        //   => (B * Q') = (Z * R) * Q' = (Z * P'^-1) * [D; O]
        //
        // D gives the relation between the new bases.
        //
        // eg)     D = [1,   1,   2,   0]
        //     A / B =  0  + 0 + Z/2 + Z
        //
        // The transition matrix to A' = (A * P'^-1) is given by
        //
        //   T' := P' * T, since
        //   T' * A' = (P' * T) * (Z * P'^-1) = P' * I_k * P'^-1 = I_k.
        //

        let E  = R1.eliminate(form: .Smith)

        let divisors = (E.diagonal + Array(repeating: R.zero, count: k - l)).filter{ $0 != .identity }
        let s = divisors.count

        let A2 = A * E.leftInverse.submatrix(colRange: (k - s) ..< k)
        let T2 = E.left.submatrix(rowRange: (k - s) ..< k) * T

        // create summands

        let newGenerators = A2.generateElements(from: generators)
        let summands = zip(newGenerators, divisors).map { (z, a) in
            return SimpleModuleStructure<A, R>.Summand(z, a)
        }

        let factorizer = { (z: FreeModule<A, R>) -> [R] in
            let n = generators.count
            let v = T2 * ComputationalMatrix(rows: n, cols: 1, grid: z.factorize(by: generators))

            return summands.enumerated().map { (i, s) in
                return s.isFree ? v[i, 0] : v[i, 0] % s.divisor
            }
        }

        return SimpleModuleStructure(summands, factorizer)
    }
}

public typealias AbstractSimpleModuleStructure<R: EuclideanRing> = SimpleModuleStructure<Int, R>

public extension AbstractSimpleModuleStructure where A == Int {
    public convenience init(rank r: Int, torsions: [R] = []) {
        let summands = (0 ..< r).map{ i in Summand(i, .zero) }
            + torsions.enumerated().map{ (i, d) in Summand(FreeModule(i + r), d) }

        self.init(summands)
    }

    public static func invariantFactorDecomposition(rank r: Int, relationMatrix B: ComputationalMatrix<R>) -> AbstractSimpleModuleStructure<R> {
            return invariantFactorDecomposition(generators: (0 ..< r).toArray(),
                                                generatingMatrix: ComputationalMatrix.identity(r),
                                                relationMatrix: B,
                                                transitionMatrix: ComputationalMatrix.identity(r))
    }

    public static func ⊕(a: AbstractSimpleModuleStructure<R>, b: AbstractSimpleModuleStructure<R>) -> AbstractSimpleModuleStructure<R> {
        return AbstractSimpleModuleStructure(rank: a.rank + b.rank, torsions: a.torsions + b.torsions)
    }
}

