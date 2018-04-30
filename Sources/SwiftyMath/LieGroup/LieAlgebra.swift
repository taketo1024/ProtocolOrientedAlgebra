//
//  LieAlgebra.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/23.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public protocol LieAlgebra: VectorSpace {
    func bracket(_ Y: Self) -> Self
    static var adjointRepresentation: LieAlgebraRepresentation<Self, Self> { get }
}

public extension LieAlgebra {
    // MEMO ad[X] = [X, -]
    public static var adjointRepresentation: LieAlgebraRepresentation<Self, Self> {
        return LieAlgebraRepresentation { (X) -> LinearEnd<Self> in
            LinearEnd { Y in X.bracket(Y) }
        }
    }
}

public func bracket<𝔤: LieAlgebra>(_ X: 𝔤, _ Y: 𝔤) -> 𝔤 {
    return X.bracket(Y)
}

public protocol FiniteDimLieAlgebra: LieAlgebra, FiniteDimVectorSpace {
    static var killingForm: BilinearForm<Self> { get }
}


public extension FiniteDimLieAlgebra {
    // B(X, Y) = tr(ad(X) ∘ ad(Y))
    public static var killingForm: BilinearForm<Self> {
        let ad = adjointRepresentation
        return BilinearForm<Self> { (X: Self, Y: Self) -> CoeffRing in
            (ad[X] ∘ ad[Y]).trace
        }
    }
}

// commutes with bracket: f[X, Y] = [f(X), f(Y)]
public protocol LieAlgebraHomType: LinearMapType where Domain: LieAlgebra, Codomain: LieAlgebra {}

public typealias LieAlgebraHom<𝔤1: LieAlgebra, 𝔤2: LieAlgebra> = LinearMap<𝔤1, 𝔤2> where 𝔤1.CoeffRing == 𝔤2.CoeffRing
extension LieAlgebraHom: LieAlgebraHomType where Domain: LieAlgebra, Codomain: LieAlgebra, Domain.CoeffRing == Codomain.CoeffRing {}


// ρ: 𝔤 -> End(V)
public typealias LieAlgebraRepresentation<𝔤: LieAlgebra, V: VectorSpace> = LieAlgebraHom<𝔤, LinearEnd<V>> where 𝔤.CoeffRing == V.CoeffRing
extension LieAlgebraHom where Domain: LieAlgebra, Codomain: LinearEndType, Domain.CoeffRing == Codomain.CoeffRing {
    public subscript(_ x: Domain) -> Codomain {
        return applied(to: x)
    }
}
