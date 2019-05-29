//
//  LinearMap.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/02.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol LinearMapType: ModuleHomType, VectorSpace where Domain: VectorSpace, Codomain: VectorSpace { }

public extension LinearMapType where Domain: FiniteDimVectorSpace, Codomain: FiniteDimVectorSpace {
    public init(matrix: Matrix<CoeffRing>) {
        self.init{ v in
            let x = Vector(v.standardCoordinates)
            let y = matrix * x
            return zip(y.grid, Codomain.standardBasis).sum { (a, w) in a * w }
        }
    }
    
    public var asMatrix: Matrix<CoeffRing> {
        let comps = Domain.standardBasis.enumerated().flatMap { (j, v) -> [MatrixComponent<CoeffRing>] in
            let w = self.applied(to: v)
            return w.standardCoordinates.enumerated().map { (i, a) in MatrixComponent(i, j, a) }
        }
        return Matrix(rows: Codomain.dim, cols: Domain.dim, components: comps)
    }
    
    public var trace: CoeffRing {
        return asMatrix.trace
    }
    
    public var determinant: CoeffRing {
        return asMatrix.determinant
    }
}

public typealias LinearMap<Domain: VectorSpace, Codomain: VectorSpace> = ModuleHom<Domain, Codomain> where Domain.CoeffRing == Codomain.CoeffRing
extension LinearMap: VectorSpace, LinearMapType where Domain: VectorSpace, Codomain: VectorSpace, Domain.CoeffRing == Codomain.CoeffRing { }

public protocol LinearEndType: LinearMapType, EndType {}

public typealias LinearEnd<Domain: VectorSpace> = LinearMap<Domain, Domain>
extension Map: LinearEndType where Domain == Codomain, Domain: VectorSpace { }

public protocol LinearAutType: AutType where Domain: VectorSpace { }

public typealias LinearAut<Domain: VectorSpace> = Aut<Domain>
extension LinearAut: LinearAutType where Domain: VectorSpace { }
