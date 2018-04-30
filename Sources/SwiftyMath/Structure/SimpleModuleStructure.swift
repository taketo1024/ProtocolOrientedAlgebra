//
//  ModuleDecomposition.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/06.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

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

public final class SimpleModuleStructure<A: BasisElementType, R: EuclideanRing>: ModuleStructure<R> {
    public let summands: [Summand]
    
    internal let basis: [A]
    internal let transform: Matrix<R>
    
    // root initializer
    internal init(_ summands: [Summand], _ basis: [A], _ transform: Matrix<R>) {
        self.summands = summands
        self.basis = basis
        self.transform = transform
        
        super.init()
    }
    
    public convenience init(generators: [A], relationMatrix B: Matrix<R>) {
        let I = Matrix<R>.identity(size: generators.count)
        self.init(basis: generators, generatingMatrix: I, relationMatrix: B, transitionMatrix: I)
    }
    
    public convenience init(basis: [A], generatingMatrix A: Matrix<R>, relationMatrix B: Matrix<R>, transitionMatrix T: Matrix<R>) {
        
        assert(A.rows == B.rows)
        assert(A.rows >= A.cols)  // n ≧ k
        assert(A.cols >= B.cols)  // k ≧ l
        
        let (k, l) = (A.cols, B.cols)
        
        // R ∈ M(k, l) : B = A * R.
        //
        // R = T * B, since
        //     T * A = I_k,
        //     T * B = T * (A * R) = I_k * R = R.
        //
        // R gives the structure of the quotient A / B.
        
        var R1 = T * B
        
        // Retake bases of A and B to obtain the decomposition of M.
        //
        //   P' * R * Q' = [D'; O].
        //   => (B * Q') = (Z * R) * Q' = (Z * P'^-1) * [D; O]
        //
        // D gives the relation between the new bases.
        //
        // eg)     D = [1,   1,   2,   0]
        //     A / B =  0  + 0 + Z/2 + Z
        
        let E  = R1.eliminate(form: .Smith)
        
        let divisors = (E.diagonal + Array(repeating: R.zero, count: k - l)).filter{ $0 != .identity }
        let s = divisors.count
        
        let A2 = A * E.leftInverse.submatrix(colRange: (k - s) ..< k)
        let generators = (0 ..< A2.cols).map { j in
            A2.nonZeroComponents(ofCol: j).sum { c in FreeModule(basis[c.row], c.value) }
        }
        
        let summands = zip(generators, divisors).map { (z, a) in
            return SimpleModuleStructure<A, R>.Summand(z, a)
        }
        
        // The transition matrix to A' = (A * P'^-1) is given by
        //
        //   T' := P' * T, since
        //   T' * A' = (P' * T) * (Z * P'^-1) = P' * I_k * P'^-1 = I_k.
        //

        let T2 = E.left.submatrix(rowRange: (k - s) ..< k) * T
        
        self.init(summands, basis, T2)
    }
    
    public static var zeroModule: SimpleModuleStructure<A, R> {
        return SimpleModuleStructure([], [], .zero(rows: 0, cols: 0))
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
    
    public var torsionCoeffs: [R] {
        return summands.filter{ !$0.isFree }.map{ $0.divisor }
    }
    
    public var generators: [FreeModule<A, R>] {
        return summands.map{ $0.generator }
    }
    
    public func generator(_ i: Int) -> FreeModule<A, R> {
        return summands[i].generator
    }
    
    public func factorize(_ z: FreeModule<A, R>) -> [R] {
        let n = basis.count
        let v = transform * Matrix(rows: n, cols: 1, grid: z.factorize(by: basis))
        
        return summands.enumerated().map { (i, s) in
            return s.isFree ? v[i, 0] : v[i, 0] % s.divisor
        }
    }
    
    public func elementIsZero(_ z: FreeModule<A, R>) -> Bool {
        return factorize(z).forAll{ $0 == .zero }
    }
    
    public func elementsAreEqual(_ z1: FreeModule<A, R>, _ z2: FreeModule<A, R>) -> Bool {
        return elementIsZero(z1 - z2)
    }
    
    public func subSummands(_ indices: Int ...) -> SimpleModuleStructure<A, R> {
        return subSummands(indices: indices)
    }
    
    public func subSummands(indices: [Int]) -> SimpleModuleStructure<A, R> {
        let sub = indices.map{ summands[$0] }
        let T = transform.submatrix({ i in indices.contains(i)}, { _ in true })
        return SimpleModuleStructure(sub, basis, T)
    }
    
    public static func ==(a: SimpleModuleStructure<A, R>, b: SimpleModuleStructure<A, R>) -> Bool {
        return a.summands == b.summands
    }
    
    public override var description: String {
        return summands.isEmpty ? "0" : summands.map{$0.description}.joined(separator: " ⊕ ")
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
        
        public var degree: Int {
            return generator.degree
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

public typealias AbstractSimpleModuleStructure<R: EuclideanRing> = SimpleModuleStructure<AbstractBasisElement, R>

public extension AbstractSimpleModuleStructure where A == AbstractBasisElement {
    public convenience init(rank r: Int, torsions: [R] = []) {
        let t = torsions.count
        let basis = (0 ..< r + t).map{ i in A(i) }
        let summands = (0 ..< r).map{ i in Summand(basis[i], .zero) }
            + torsions.enumerated().map{ (i, d) in Summand(basis[i + r], d) }
        let I = Matrix<R>.identity(size: r + t)
        self.init(summands, basis, I)
    }
    
    public static func ⊕(a: AbstractSimpleModuleStructure<R>, b: AbstractSimpleModuleStructure<R>) -> AbstractSimpleModuleStructure<R> {
        return AbstractSimpleModuleStructure(
            rank: a.rank + b.rank,
            torsions: a.torsionCoeffs + b.torsionCoeffs
        )
    }
}

extension SimpleModuleStructure: Codable where A: Codable, R: Codable {
    enum CodingKeys: String, CodingKey {
        case summands, basis, transform
    }
    
    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let summands = try c.decode([Summand].self, forKey: .summands)
        let basis = try c.decode([A].self, forKey: .basis)
        let trans = try c.decode(Matrix<R>.self, forKey: .transform)
        self.init(summands, basis, trans)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(summands, forKey: .summands)
        try c.encode(basis, forKey: .basis)
        try c.encode(transform, forKey: .transform)
    }
}

extension SimpleModuleStructure.Summand: Codable where A: Codable, R: Codable {
    enum CodingKeys: String, CodingKey {
        case generator, divisor
    }
    
    public convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let g = try c.decode(FreeModule<A, R>.self, forKey: .generator)
        let d = try c.decode(R.self, forKey: .divisor)
        self.init(g, d)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(generator, forKey: .generator)
        try c.encode(divisor, forKey: .divisor)
    }
}
