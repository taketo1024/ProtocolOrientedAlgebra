//
//  VectorSpace.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/18.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol VectorSpace: Module where CoeffRing: Field { }

public protocol FiniteDimVectorSpace: VectorSpace {
    static var dim: Int { get }
    static var standardBasis: [Self] { get }
    var standardCoordinates: [CoeffRing] { get }
}

public typealias ProductVectorSpace<X: VectorSpace, Y: VectorSpace> = ProductModule<X, Y> where X.CoeffRing == Y.CoeffRing
extension ProductVectorSpace: VectorSpace where Left: VectorSpace, Right: VectorSpace, Left.CoeffRing == Right.CoeffRing {}

public protocol LinearMapType: ModuleHomType, VectorSpace where Domain: VectorSpace, Codomain: VectorSpace { }

public extension LinearMapType where Domain: FiniteDimVectorSpace, Codomain: FiniteDimVectorSpace {
    init(matrix: DMatrix<CoeffRing>) {
        self.init{ v in
            let x = DVector(v.standardCoordinates)
            let y = matrix * x
            return zip(y.grid, Codomain.standardBasis).sum { (a, w) in a * w }
        }
    }
    
    var asMatrix: DMatrix<CoeffRing> {
        let comps = Domain.standardBasis.enumerated().flatMap { (j, v) -> [MatrixComponent<CoeffRing>] in
            let w = self.applied(to: v)
            return w.standardCoordinates.enumerated().map { (i, a) in MatrixComponent(i, j, a) }
        }
        return DMatrix(rows: Codomain.dim, cols: Domain.dim, components: comps)
    }
}

public typealias LinearMap<Domain: VectorSpace, Codomain: VectorSpace> = ModuleHom<Domain, Codomain> where Domain.CoeffRing == Codomain.CoeffRing
extension LinearMap: VectorSpace, LinearMapType where Domain: VectorSpace, Codomain: VectorSpace, Domain.CoeffRing == Codomain.CoeffRing { }

public protocol LinearEndType: LinearMapType, EndType {}

public typealias LinearEnd<Domain: VectorSpace> = LinearMap<Domain, Domain>
extension LinearMap: LinearEndType where Domain == Codomain, Domain: VectorSpace { }


public protocol BilinearMapType: MapType, VectorSpace
    where Domain: ProductSetType,
    Domain.Left: VectorSpace,
    Domain.Right: VectorSpace,
    Codomain: VectorSpace,
    CoeffRing == Domain.Left.CoeffRing,
    CoeffRing == Domain.Right.CoeffRing,
CoeffRing == Codomain.CoeffRing {
    
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain)
    func applied(to: (Domain.Left, Domain.Right)) -> Codomain
}

public extension BilinearMapType {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain) {
        self.init { (v: Domain) in f(v.left, v.right) }
    }
    
    func applied(to v: (Domain.Left, Domain.Right)) -> Codomain {
        return applied(to: Domain(v.0, v.1))
    }
    
    static var zero: Self {
        return Self{ v in .zero }
    }
    
    static func +(f: Self, g: Self) -> Self {
        return Self { v in f.applied(to: v) + g.applied(to: v) }
    }
    
    static prefix func -(f: Self) -> Self {
        return Self { v in -f.applied(to: v) }
    }
    
    static func *(r: CoeffRing, f: Self) -> Self {
        return Self { v in r * f.applied(to: v) }
    }
    
    static func *(f: Self, r: CoeffRing) -> Self {
        return Self { v in f.applied(to: v) * r }
    }
}

public struct BilinearMap<V1: VectorSpace, V2: VectorSpace, W: VectorSpace>: BilinearMapType where V1.CoeffRing == V2.CoeffRing, V1.CoeffRing == W.CoeffRing {
    public typealias CoeffRing = V1.CoeffRing
    public typealias Domain = ProductVectorSpace<V1, V2>
    public typealias Codomain = W
    
    private let fnc: (ProductVectorSpace<V1, V2>) -> W
    public init(_ fnc: @escaping (ProductVectorSpace<V1, V2>) -> W) {
        self.fnc = fnc
    }
    
    public func applied(to v: ProductVectorSpace<V1, V2>) -> W {
        return fnc(v)
    }
}

public protocol BilinearFormType: BilinearMapType where Domain.Left == Domain.Right, Codomain == AsVectorSpace<CoeffRing> {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> CoeffRing)
    subscript(x: Domain.Left, y: Domain.Right) -> CoeffRing { get }
}

public extension BilinearFormType {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> CoeffRing) {
        self.init{ v in AsVectorSpace( f(v.left, v.right) ) }
    }
    
    subscript(x: Domain.Left, y: Domain.Right) -> CoeffRing {
        return self.applied(to: (x, y)).value
    }
}

public extension BilinearFormType where Domain.Left: FiniteDimVectorSpace {
    var asMatrix: DMatrix<CoeffRing> {
        typealias V = Domain.Left
        
        let n = V.dim
        let basis = V.standardBasis
        
        return DMatrix(rows: n, cols: n) { (i, j) in
            let (v, w) = (basis[i], basis[j])
            return self.applied(to: (v, w)).value
        }
    }
}

public typealias BilinearForm<V: VectorSpace> = BilinearMap<V, V, AsVectorSpace<V.CoeffRing>>

extension BilinearMap: BilinearFormType where Domain.Left == Domain.Right, Codomain == AsVectorSpace<Domain.CoeffRing> {}
