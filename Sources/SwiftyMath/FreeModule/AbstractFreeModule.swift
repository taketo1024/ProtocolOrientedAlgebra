//
//  File.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/11.
//

public struct AbstractBasisElement: BasisElementType {
    public let index: Int
    public init(_ index: Int) {
        self.index = index
    }
    
    public static func generateBasis(_ size: Int) -> [AbstractBasisElement] {
        return (0 ..< size).map{ AbstractBasisElement($0) }
    }
    
    public static func < (e1: AbstractBasisElement, e2: AbstractBasisElement) -> Bool {
        return e1.index < e2.index
    }
    
    public var description: String {
        return "e\(Format.sub(index))"
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
        return AbstractTensorModule( self.map{ (e, a) in (Tensor(e), a) } )
    }
    
    public static func standardBasis(dim: Int) -> [AbstractFreeModule<CoeffRing>] {
        let basis = AbstractBasisElement.generateBasis(dim)
        return basis.map { e in AbstractFreeModule(e) }
    }
}

public typealias AbstractTensorModule<R: Ring> = FreeModule<Tensor<AbstractBasisElement>, R>

public extension AbstractTensorModule where A == Tensor<AbstractBasisElement> {
    public static func ⊗(v: AbstractTensorModule<CoeffRing>, w: AbstractTensorModule<CoeffRing>) -> AbstractTensorModule<CoeffRing> {
        return v.basis.allCombinations(with: w.basis).sum { (e1, e2) -> AbstractTensorModule<CoeffRing> in
            let t = e1 ⊗ e2
            return AbstractTensorModule(t, v[e1] * w[e2])
        }
    }
}

public typealias AbstractFreeModuleHom<K: Ring> = FreeModuleHom<AbstractBasisElement, AbstractBasisElement, K>

public extension AbstractFreeModuleHom where A == AbstractBasisElement, A == B {
    public init(matrix: Matrix<R>) {
        self.init { (e: AbstractBasisElement) -> AbstractFreeModule<R> in
            AbstractFreeModule(matrix.colVector(e.index).grid)
        }
    }
    
    public var asTensor: AbstractTensorModuleHom<R> {
        return AbstractTensorModuleHom { (e: Tensor<AbstractBasisElement>) -> AbstractTensorModule<R> in
            (e.factors.count == 1) ? self.applied(to: e.factors[0]).asTensor : .zero
        }
    }
}

public typealias AbstractTensorModuleHom<K: Ring> = FreeModuleHom<Tensor<AbstractBasisElement>, Tensor<AbstractBasisElement>, K>

public extension AbstractTensorModuleHom where A == Tensor<AbstractBasisElement>, A == B {
    public static func ⊗(f: AbstractTensorModuleHom<CoeffRing>, g: AbstractTensorModuleHom<CoeffRing>) -> AbstractTensorModuleHom<CoeffRing> {
        return AbstractTensorModuleHom { (e: Tensor<AbstractBasisElement>) -> AbstractTensorModule<CoeffRing> in
            let n = e.factors.count
            return (0 ..< n).sum { i in
                let e1 = Tensor(e.factors.prefix(i).toArray())
                let e2 = Tensor(e.factors.suffix(n - i).toArray())
                return f.applied(to: e1) ⊗ g.applied(to: e2)
            }
        }
    }
}
