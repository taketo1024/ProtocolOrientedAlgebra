//
//  VectorSpace.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/18.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public protocol VectorSpace: Module where BaseRing: Field { }

public protocol FiniteDimVectorSpace: VectorSpace {
    static var dim: Int { get }
    static var standardBasis: [Self] { get }
    var standardCoordinates: [BaseRing] { get }
}

public typealias ProductVectorSpace<X: VectorSpace, Y: VectorSpace> = ProductModule<X, Y> where X.BaseRing == Y.BaseRing
extension ProductVectorSpace: VectorSpace where Left: VectorSpace, Right: VectorSpace, Left.BaseRing == Right.BaseRing {}

public protocol LinearMapType: ModuleHomType, VectorSpace where Domain: VectorSpace, Codomain: VectorSpace { }

public extension LinearMapType where Domain: FiniteDimVectorSpace, Codomain: FiniteDimVectorSpace {
    init(matrix: DMatrix<BaseRing>) {
        self.init{ v in
            let x = DVector(v.standardCoordinates)
            let y = matrix * x
            return .combine(basis: Codomain.standardBasis, vector: y)
        }
    }
    
    var asMatrix: DMatrix<BaseRing> {
        let (n, m) = (Codomain.dim, Domain.dim)
        return DMatrix(size: (n, m)) { setEntry in
            for j in 0 ..< m {
                let v = Domain.standardBasis[j]
                let w = self(v)
                w.standardCoordinates.enumerated().forEach { (i, a) in
                    setEntry(i, j, a)
                }
            }
        }
    }
}

public typealias LinearMap<Domain: VectorSpace, Codomain: VectorSpace> = ModuleHom<Domain, Codomain> where Domain.BaseRing == Codomain.BaseRing
extension LinearMap: VectorSpace, LinearMapType where Domain: VectorSpace, Codomain: VectorSpace, Domain.BaseRing == Codomain.BaseRing { }

public protocol LinearEndType: LinearMapType, EndType {}

public typealias LinearEnd<Domain: VectorSpace> = LinearMap<Domain, Domain>
extension LinearMap: LinearEndType where Domain == Codomain, Domain: VectorSpace { }

public typealias AsVectorSpace<R: Field> = AsModule<R>

extension AsVectorSpace: VectorSpace, FiniteDimVectorSpace where R: Field {
    public static var dim: Int {
        return 1
    }
    
    public static var standardBasis: [AsVectorSpace<R>] {
        return [AsVectorSpace(.identity)]
    }
    
    public var standardCoordinates: [R] {
        return [value]
    }
}
