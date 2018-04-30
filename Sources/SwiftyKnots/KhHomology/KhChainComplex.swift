//
//  KhovanovHomology.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import SwiftyMath

public struct KhCube {
    public struct Vertex {
        public let state: LinkSpliceState
        public let components: [Link.Component]
        public let basis: [KhTensorElement]
    }
    
    public let vertices: [LinkSpliceState : Vertex]
    
    public init(_ L: Link) {
        let (n, n⁺, n⁻) = (L.crossingNumber, L.crossingNumber⁺, L.crossingNumber⁻)
        
        self.vertices = Dictionary(keys: LinkSpliceState.all(n)) { s -> Vertex in
            let sL = L.spliced(by: s)
            let comps = sL.components
            let basis = KhTensorElement.generateBasis(state: s, power: comps.count, shift: n⁺ - 2 * n⁻)
            return Vertex(state: s, components: comps, basis: basis)
        }
    }
    
    public subscript(s: LinkSpliceState) -> Vertex {
        return vertices[s]!
    }
    
    public subscript(i: Int) -> [Vertex] {
        return vertices.values.filter{ $0.state.degree == i }
    }
    
    public func map<R: Ring>(_ x: KhTensorElement, _ μ: KhBasisElement.Product, _ Δ: KhBasisElement.Coproduct) -> FreeModule<KhTensorElement, R> {
        let s = x.state
        return s.next.sum { (sgn, next) in
            let (c1, c2) = (self[s].components, self[next].components)
            let (d1, d2) = (c1.filter{ !c2.contains($0) }, c2.filter{ !c1.contains($0) })
            
            switch (d1.count, d2.count) {
            case (2, 1): // apply μ
                let (i1, i2, j) = (c1.index(of: d1[0])!, c1.index(of: d1[1])!, c2.index(of: d2[0])!)
                return R(from: sgn) * x.product(μ, (i1, i2), j, next)
                
            case (1, 2): // apply Δ
                let (i, j1, j2) = (c1.index(of: d1[0])!, c2.index(of: d2[0])!, c2.index(of: d2[1])!)
                return R(from: sgn) * x.coproduct(Δ, i, (j1, j2), next)
                
            default:
                fatalError()
            }
        }
    }
    
    public func map<R: Ring>(_ x: FreeModule<KhTensorElement, R>, _ μ: KhBasisElement.Product, _ Δ: KhBasisElement.Coproduct) -> FreeModule<KhTensorElement, R> {
        return x.sum { (a, r) in r * self.map(a, μ, Δ) }
    }
}

public extension Link {
    public func KhChainComplex<R: EuclideanRing>(_ type: R.Type) -> (KhCube, CochainComplex<KhTensorElement, R>) {
        typealias C = CochainComplex<KhTensorElement, R>
        
        let name = "CKh(\(self.name); \(R.symbol))"
        let (n, n⁻) = (crossingNumber, crossingNumber⁻)
        
        let cube = KhCube(self)
        let chain = (0 ... n).map { i -> (C.ChainBasis, C.BoundaryMap) in
            let (μ, Δ) = (KhBasisElement.μ, KhBasisElement.Δ)
            
            let chainBasis = cube[i].flatMap { v in v.basis }
            let boundaryMap = C.BoundaryMap { (x: KhTensorElement) in cube.map(x, μ, Δ) }
            return (chainBasis, boundaryMap)
        }
        
        return (cube, CochainComplex(name: name, chain: chain, offset: -n⁻))
    }
}
