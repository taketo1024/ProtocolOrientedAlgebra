//
//  ChainComplex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/04.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol ChainType {
    static var descending: Bool { get }
    static var degree: Int { get }
}
public struct Descending : ChainType {    // for ChainComplex / Homology
    public static let descending = true
    public static var degree: Int { return -1 }
}
public struct Ascending : ChainType {
    public static let descending = false
    public static var degree: Int { return +1 }
}

public typealias   ChainComplex<A: BasisElementType, R: Ring> = _ChainComplex<Descending, A, R>
public typealias CochainComplex<A: BasisElementType, R: Ring> = _ChainComplex<Ascending,  A, R>

public class _ChainComplex<T: ChainType, A: BasisElementType, R: Ring>: Equatable, CustomStringConvertible {
    public typealias Chain = FreeModule<A, R>
    public typealias ChainBasis = [A]
    public typealias BoundaryMap = FreeModuleHom<A, A, R>
    
    public let name: String
    
    internal let chain: [(basis: ChainBasis, map: BoundaryMap)]
    internal let offset: Int
    internal var matrices: [Matrix<R>?]
    
    // root initializer
    public init(name: String? = nil, chain: [(ChainBasis, BoundaryMap)], offset: Int = 0) {
        self.name = name ?? (T.descending ? "C" : "C*")
        self.chain = chain
        self.matrices = Array(repeating: nil, count: chain.count)
        self.offset = offset
    }
    
    public var isEmpty: Bool {
        return chain.isEmpty
    }
    
    public var validDegrees: [Int] {
        return isEmpty ? [] : (offset ... topDegree).toArray()
    }
    
    public var topDegree: Int {
        return chain.count + offset - 1
    }
    
    public func chainBasis(_ i: Int) -> ChainBasis {
        return (offset ... topDegree).contains(i) ? chain[i - offset].basis : []
    }
    
    public func boundaryMap(_ i: Int) -> BoundaryMap {
        return (offset ... topDegree).contains(i) ? chain[i - offset].map : .zero
    }
    
    public func boundaryMatrix(_ i: Int) -> Matrix<R> {
        switch i {
        case (offset ... topDegree):
            if let A = matrices[i - offset] {
                return A
            }
            
            let A = makeMatrix(i)
            matrices[i - offset] = A
            return A
            
        case topDegree + 1 where T.descending:
            return .zero(rows: chainBasis(topDegree).count, cols: 0)
            
        case offset - 1 where !T.descending:
            return .zero(rows: chainBasis(offset).count, cols: 0)
            
        default:
            return .zero(rows: 0, cols: 0)
        }
    }
    
    internal func makeMatrix(_ i: Int) -> Matrix<R> {
        let (from, to, map) = (chainBasis(i), chainBasis(i + T.degree), boundaryMap(i))
        let toIndex = Dictionary(pairs: to.enumerated().map{($1, $0)}) // [toBasisElement: toBasisIndex]
        let components = from.enumerated().flatMap{ (j, x) -> [MatrixComponent<R>] in
            map.applied(to: x).compactMap { (y, a) -> MatrixComponent<R>? in
                toIndex[y].flatMap{ i in MatrixComponent(i, j, a) } // nil if toIndex[y] == nil
            }
        }
        
        return Matrix(rows: to.count, cols: from.count, components: components)
    }
    
    public func shifted(_ d: Int) -> _ChainComplex<T, A, R> {
        return _ChainComplex.init(name: "\(name)[\(d)]", chain: chain, offset: offset + d)
    }
    
    public func assertComplex(debug: Bool = false) {
        (offset ... topDegree).forEach { i1 in
            let i2 = i1 + T.degree
            let b1 = chainBasis(i1)
            let (d1, d2) = (boundaryMap(i1), boundaryMap(i2))
            let (m1, m2) = (boundaryMatrix(i1), boundaryMatrix(i2))
            
            if debug {
                print("----------")
                print("C\(i1) -> C\(i2)")
                print("----------")
                print("C\(i1) : \(b1)\n")
                for s in b1 {
                    let x = d1.applied(to: s)
                    let y = d2.applied(to: x)
                    print("\t\(s) ->\t\(x) ->\t\(y)")
                }
                print()
            }
            
            let matrix = m2 * m1
            assert(matrix.isZero, "d\(i2)∘d\(i1) = \(matrix)")
        }
    }
    
    public static func ==<T, A, R>(a: _ChainComplex<T, A, R>, b: _ChainComplex<T, A, R>) -> Bool {
        let offset = min(a.offset, b.offset)
        let degree = max(a.topDegree, b.topDegree)
        return (offset ... degree).forAll { i in (a.chainBasis(i) == b.chainBasis(i)) && (a.boundaryMatrix(i) == b.boundaryMatrix(i)) }
    }
    
    public var description: String {
        return name
    }
    
    public var detailDescription: String {
        return name + " = {\n"
            + (offset ... topDegree).map{ i in "\t\(i) : \(chainBasis(i))"}.joined(separator: ",\n")
            + "\n}"
    }
}

public extension ChainComplex where T == Descending {
    public var dual: CochainComplex<Dual<A>, R> {
        typealias D = CochainComplex<Dual<A>, R>
        let cochain = validDegrees.map{ (i) -> (D.ChainBasis, D.BoundaryMap) in
            let e = R(from: (-1).pow(i + 1))
            
            let current = chainBasis(i)
            let next = chainBasis(i + 1)
            let matrix = boundaryMatrix(i + 1).transposed
            
            let dBasis = chainBasis(i).map{ Dual($0) }
            let dMap  = D.BoundaryMap { (f: Dual<A>) in
                let j = current.index(of: f.base)!
                let col = matrix.nonZeroComponents(ofCol: j)
                let elements = col.map { c in (next[c.row].dual, e * c.value) }
                return D.Chain(elements)
            }
            return (dBasis, dMap)
        }
        
        return D(name: "\(name)*", chain: cochain)
    }
}
