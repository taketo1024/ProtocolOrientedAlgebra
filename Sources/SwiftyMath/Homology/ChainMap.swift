//
//  ChainMap.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/08/01.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public typealias   ChainMap<A: BasisElementType, B: BasisElementType, R: Ring> = _ChainMap<Descending, A, B, R>
public typealias CochainMap<A: BasisElementType, B: BasisElementType, R: Ring> = _ChainMap<Ascending,  A, B, R>

// TODO conform Module<R>
public struct _ChainMap<T: ChainType, A: BasisElementType, B: BasisElementType, R: Ring>: ModuleHomType {
    public typealias CoeffRing = R
    public typealias Domain   = FreeModule<A, R>
    public typealias Codomain = FreeModule<B, R>
    
    internal let f: FreeModuleHom<A, B, R>
    
    public init(_ f: @escaping (A) -> Codomain) {
        self.init(FreeModuleHom(f))
    }
    
    public init(_ f: @escaping (Domain) -> Codomain) {
        self.init(FreeModuleHom(f))
    }
    
    public init(_ f: FreeModuleHom<A, B, R>) {
        self.f = f
    }
    
    public func applied(to a: A) -> FreeModule<B, R> {
        return f.applied(to: a)
    }
    
    public func applied(to x: FreeModule<A, R>) -> FreeModule<B, R> {
        return f.applied(to: x)
    }
    
    public static func ∘<C>(g: _ChainMap<T, B, C, R>, f: _ChainMap<T, A, B, R>) -> _ChainMap<T, A, C, R> {
        return _ChainMap<T, A, C, R>(g.f ∘ f.f)
    }
    
    public func assertChainMap(from: _ChainComplex<T, A, R>, to: _ChainComplex<T, B, R>, debug: Bool = false) {
        (min(from.offset, to.offset) ... max(from.topDegree, to.topDegree)).forEach { i in
            
            //          f
            //   C[i] -----> C'[i]
            //     |          |
            //   d1|          |d2
            //     v          v
            //  C[i-1] ---> C'[i-1]
            //          f
            
            let basis = from.chainBasis(i)
            if debug {
                print("C\(i) : \(basis)\n")
            }
            
            let d1 = from.boundaryMap(i)
            
            for a in basis {
                let x1 = f.applied(to: a)
                let d2 = to.boundaryMap(x1.degree)
                let x2 = d2.applied(to: x1)
                
                let y1 = d1.applied(to: a)
                let y2 = f.applied(to: y1)
                
                if debug {
                    print("\td2 ∘ f1: \(a) ->\t\(x1) ->\t\(x2)")
                    print("\tf2 ∘ d1: \(a) ->\t\(y1) ->\t\(y2)")
                    print()
                }
                
                assert(x2 == y2)
            }
        }
    }
}

public extension ChainMap where T == Descending {
    
    // f: C1 -> C2  ==>  f^*: Hom(C1, R) <- Hom(C1, R) , pullback
    //                        g∘f        <- g

    public func dual(domain C: ChainComplex<A, R>) -> CochainMap<Dual<B>, Dual<A>, R> {
        return CochainMap { (d: Dual<B>) -> FreeModule<Dual<A>, R> in
            let i = d.degree
            let values = C.chainBasis(i).compactMap { s -> (Dual<A>, R)? in
                let a = self.applied(to: s)[d.base]
                return (a != .zero) ? (Dual(s), a) : nil
            }
            return FreeModule(values)
        }
    }
}
