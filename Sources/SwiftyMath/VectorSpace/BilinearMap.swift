//
//  BilinearMap.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/02.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

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
    public init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain) {
        self.init { (v: Domain) in f(v.left, v.right) }
    }

    public func applied(to v: (Domain.Left, Domain.Right)) -> Codomain {
        return applied(to: Domain(v.0, v.1))
    }

    public static var zero: Self {
        return Self{ v in .zero }
    }

    public static func +(f: Self, g: Self) -> Self {
        return Self { v in f.applied(to: v) + g.applied(to: v) }
    }

    public static prefix func -(f: Self) -> Self {
        return Self { v in -f.applied(to: v) }
    }

    public static func *(r: CoeffRing, f: Self) -> Self {
        return Self { v in r * f.applied(to: v) }
    }

    public static func *(f: Self, r: CoeffRing) -> Self {
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
    public init(_ f: @escaping (Domain.Left, Domain.Right) -> CoeffRing) {
        self.init{ v in AsVectorSpace( f(v.left, v.right) ) }
    }

    public subscript(x: Domain.Left, y: Domain.Right) -> CoeffRing {
        return self.applied(to: (x, y)).value
    }
}

public extension BilinearFormType where Domain.Left: FiniteDimVectorSpace {
    public var asMatrix: Matrix<CoeffRing> {
        typealias V = Domain.Left

        let n = V.dim
        let basis = V.standardBasis

        return Matrix(rows: n, cols: n) { (i, j) in
            let (v, w) = (basis[i], basis[j])
            return self.applied(to: (v, w)).value
        }
    }
}

public typealias BilinearForm<V: VectorSpace> = BilinearMap<V, V, AsVectorSpace<V.CoeffRing>>

extension BilinearMap: BilinearFormType where Domain.Left == Domain.Right, Codomain == AsVectorSpace<Domain.CoeffRing> {}




// MEMO This causes Segmentation Fault for some reason...

//public typealias BilinearMap<V1: VectorSpace, V2: VectorSpace, W: VectorSpace> = Map<ProductVectorSpace<V1, V2>, W> where
//    V1.CoeffRing == V2.CoeffRing,
//    V1.CoeffRing == W.CoeffRing
//
//extension BilinearMap: VectorSpace, BilinearMapType
//  where Domain: ProductSetType & VectorSpace,
//        Domain.Left: VectorSpace,
//        Domain.Right: VectorSpace,
//        Codomain: VectorSpace,
//        Domain.CoeffRing == Codomain.CoeffRing,
//        Domain.CoeffRing == Domain.Left.CoeffRing,
//        Domain.CoeffRing == Domain.Right.CoeffRing {
//}

//public typealias BilinearForm<V: VectorSpace> = BilinearMap<V, V, AsVectorSpace<V.CoeffRing>>
//
//extension BilinearForm: BilinearFormType
//  where Domain: ProductSetType & VectorSpace,
//        Domain.Left: VectorSpace,
//        Domain.Left == Domain.Right,
//        Domain.CoeffRing == Domain.Left.CoeffRing,
//        Codomain == AsVectorSpace<Domain.CoeffRing> {
//}

//public struct BilinearForm<V: VectorSpace>: BilinearFormType {
//    public typealias CoeffRing = V.CoeffRing
//    public typealias Domain = ProductVectorSpace<V, V>
//    public typealias Codomain = AsVectorSpace<V.CoeffRing>
//
//    internal let fnc: (Domain) -> Codomain
//    public init(_ fnc: @escaping (Domain) -> Codomain) {
//        self.fnc = fnc
//    }
//
//    public func applied(to x: Domain) -> Codomain {
//        return fnc(x)
//    }
//}
