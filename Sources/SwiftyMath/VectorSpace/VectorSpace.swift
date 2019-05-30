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

// MEMO not made as a subprotocol of VectorSpace,
// to avoid multi-inheritance.
public protocol NormedSpace {
    var norm: 𝐑 { get }
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
