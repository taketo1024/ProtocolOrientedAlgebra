//
//  File.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/11.
//

import Foundation

public struct AbstractBasisElement: BasisElementType {
    public let index: Int
    public let label: String
    
    public init(_ index: Int, label: String? = nil) {
        self.index = index
        self.label = label ?? "e\(Format.sub(index))"
    }
    
    public static func generateBasis(_ size: Int) -> [AbstractBasisElement] {
        return (0 ..< size).map{ AbstractBasisElement($0) }
    }
    
    public static func == (e1: AbstractBasisElement, e2: AbstractBasisElement) -> Bool {
        return e1.index == e2.index
    }
    
    public static func < (e1: AbstractBasisElement, e2: AbstractBasisElement) -> Bool {
        return e1.index < e2.index
    }
    
    public var hashValue: Int {
        return index
    }
    
    public var description: String {
        return label
    }
}

public typealias AbstractFreeModule<R: Ring> = FreeModule<AbstractBasisElement, R>

extension AbstractFreeModule where A == AbstractBasisElement {
    public init(_ components: [CoeffRing]) {
        self.init(basis: AbstractBasisElement.generateBasis(components.count), components: components)
    }
    
    public init(_ components: CoeffRing ...) {
        self.init(components)
    }
    
    public var asTensor: AbstractTensorModule<CoeffRing> {
        return self.mapBasis{ e in FreeTensor(e) }
    }
    
    public static func standardBasis(dim: Int) -> [AbstractFreeModule<CoeffRing>] {
        let basis = AbstractBasisElement.generateBasis(dim)
        return basis.map { e in .wrap(e) }
    }
}

public typealias AbstractTensorModule<R: Ring> = FreeModule<FreeTensor<AbstractBasisElement>, R>

public extension AbstractTensorModule where A == FreeTensor<AbstractBasisElement> {
    static func ⊗(v: AbstractTensorModule<CoeffRing>, w: AbstractTensorModule<CoeffRing>) -> AbstractTensorModule<CoeffRing> {
        return v.basis.allCombinations(with: w.basis).sum { (e1, e2) -> AbstractTensorModule<CoeffRing> in
            let r = v[e1] * w[e2]
            let t = e1 ⊗ e2
            return r * .wrap(t)
        }
    }
}

public typealias AbstractFreeModuleHom<K: Ring> = FreeModuleHom<AbstractBasisElement, AbstractBasisElement, K>

public extension AbstractFreeModuleHom where A == AbstractBasisElement, A == B {
    init(matrix: DMatrix<R>) {
        self.init { (e: AbstractBasisElement) -> AbstractFreeModule<R> in
            AbstractFreeModule(matrix.colVector(e.index).grid)
        }
    }
    
    var asTensor: AbstractTensorModuleHom<R> {
        return AbstractTensorModuleHom { (e: FreeTensor<AbstractBasisElement>) -> AbstractTensorModule<R> in
            (e.factors.count == 1) ? self.applied(to: e.factors[0]).asTensor : .zero
        }
    }
}

public typealias AbstractTensorModuleHom<K: Ring> = FreeModuleHom<FreeTensor<AbstractBasisElement>, FreeTensor<AbstractBasisElement>, K>

public extension AbstractTensorModuleHom where A == FreeTensor<AbstractBasisElement>, A == B {
    static func ⊗(f: AbstractTensorModuleHom<CoeffRing>, g: AbstractTensorModuleHom<CoeffRing>) -> AbstractTensorModuleHom<CoeffRing> {
        return AbstractTensorModuleHom { (e: FreeTensor<AbstractBasisElement>) -> AbstractTensorModule<CoeffRing> in
            let n = e.factors.count
            return (0 ..< n).sum { i in
                let e1 = FreeTensor(e.factors.prefix(i).toArray())
                let e2 = FreeTensor(e.factors.suffix(n - i).toArray())
                return f.applied(to: e1) ⊗ g.applied(to: e2)
            }
        }
    }
}
