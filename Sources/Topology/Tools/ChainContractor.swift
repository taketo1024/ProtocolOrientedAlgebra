//
//  ChainContractor.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/02/15.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public class ChainContractor<R: EuclideanRing> {
    typealias S = Simplex
    typealias C = SimplicialChain<R>

    internal let K: SimplicialComplex

    internal var step = -1
    internal var doneCells = Set<S>()
    internal var allDone = false
    internal var debug = false

    internal var generators = [S]()

    internal var fNodes = [S : Node]()
    internal var hNodes = [S : Node]()
    internal var dNodes = [S : Node]()

    public init(_ K: SimplicialComplex, _ type: R.Type, debug: Bool = false) {
        self.K = K
        self.debug = debug
        self.run()
    }

    internal func f(_ s: S) -> C {
        return fNodes[s]!.collect(flatten: allDone)
    }

    internal func f(_ c: C) -> C {
        return c.sum{ (s, a) in a * f(s) }
    }

    internal func g(_ s: S) -> C {
        return C(s) + h(C(s).boundary())
    }

    internal func g(_ c: C) -> C {
        return c.sum{ (s, a) in a * g(s) }
    }

    internal func h(_ s: S) -> C {
        return hNodes[s]!.collect(flatten: allDone)
    }

    internal func h(_ c: C, path: Bool = false) -> C {
        return c.sum{ (s, a) in a * h(s) }
    }

    internal func d(_ s: S) -> C {
        return dNodes[s]!.collect(flatten: allDone)
    }

    internal func d(_ c: C) -> C {
        return c.sum{ (s, a) in a * d(s) }
    }

    internal func makeList(_ s: S) -> [S] {
        if doneCells.contains(s) {
            return []
        }

        func extract(_ s: S) -> [S] {
            return [s] + s.faces().filter({ !doneCells.contains($0) }).flatMap{ extract($0) }
        }
        return extract(s).reversed().unique()
    }

    internal func run() {
        for s in K.maximalCells.sorted() {
            let list = makeList(s)

            for s in list {
                iteration(s)
            }
        }

        allDone = true

        if debug {
            log("")
            log("generators:")
            log(generators.map{ "\t\($0.dim): \($0)"}.joined(separator: ",\n"))

            if !dNodes.isEmpty {
                log("")
                logNodes("diffs", dNodes)
            }
            log("")

            assertChainContraction()
        }
    }

    internal func iteration(_ s: S) {
        step += 1

        let bs = C(s).boundary()
        let f_bs = f(bs)

        log("\(step)\t\(s) : f(∂\(s)) = \(f_bs)")
        log("")

        if f_bs == .zero {
            log("\tadd: \(s)")

            generators.append(s)

            fNodes[s] = Node(s, value: C(s))
            hNodes[s] = Node(s)
            dNodes[s] = Node(s)

        } else if let (t1, a) = removableGenerator(bs, f_bs) {
            log("\tremove: \(t1) = \(-a.inverse! * (f_bs - C(t1, a)))")

            generators.remove(at: generators.index(of: t1)!)

            fNodes[s] = Node(s)
            hNodes[s] = Node(s)
            dNodes[s] = Node(s)

            fNodes[t1]!.value = .zero
            fNodes[t1]!.refs = (C(t1) - a.inverse! * f_bs).map{ (t, a) in (fNodes[t]!, a) }

            hNodes[t1]!.value = -a.inverse! * C(s)
            hNodes[t1]!.refs = (C(t1) - a.inverse! * bs).map{ (t, a) in (hNodes[t]!, a) }

            log("\t\t f: \(fNodes[t1]!.detailDescription)")
            log("\t\t h: \(hNodes[t1]!.detailDescription)")

        } else {
            log("\tadd: \(s), ∂: \(f_bs)")

            generators.append(s)

            fNodes[s] = Node(s, value: C(s))
            hNodes[s] = Node(s)
            dNodes[s] = Node(s, refs: f_bs.map{ (t, a) in (fNodes[t]!, a)})
        }

        doneCells.insert(s)

        if debug {
            log("\tgenerators: \(generators)")
            log("")
        }
    }

    private func removableGenerator(_ bs: C, _ f_bs: C) -> (Simplex, R)? {
        return bs.sorted{ $0.0 > $1.0 }
            .lazy
            .filter { (t1, _) in
                f_bs[t1].isInvertible // this implies generators.contains(t1)
                    && f_bs.forAll{ (t, _) in t == t1 || !self.fNodes[t]!.passes(t1)}
                    &&   bs.forAll{ (t, _) in t == t1 || !self.hNodes[t]!.passes(t1)}
        }.first
    }

    internal func assertChainContraction() {
        // assert chain complex
        for s in generators {
            let dds = d(d(s))
            assert(dds == .zero, "∂∂\(s) = \(dds), should be zero")
        }

        // assert gf - 1 = h∂ + ∂h
        for s in doneCells {
            let a1 = g(f(s)) - C(s)
            let a2 = h(C(s).boundary()) + h(s).boundary()
            assert(a1 == a2, "(gf - 1)(\(s)) = \(a1),\n(h∂ + ∂h)(\(s)) = \(a2)\n")
        }

        // assert fg = 1
        for s in generators {
            let fgs = f(g(s))
            assert(fgs == C(s), "fg(\(s)) != \(fgs)\n")
        }

        log("\tassertion complete.")
        log("")
    }

    internal class Node: Hashable, CustomStringConvertible {
        let cell: S
        var value: C
        var refs: [(Node, R)] = []

        init(_ cell: S, value: C = .zero, refs: [(Node, R)] = []) {
            self.cell = cell
            self.value = value
            self.refs = refs
        }

        var isZeroNode: Bool {
            return value == .zero && refs.isEmpty
        }

        func collect(flatten: Bool = false) -> C {
            if refs.isEmpty {
                return self.value
            }

            let result = value +
                refs.filter{ !$0.0.isZeroNode }
                    .sum { (n, r) in r * n.collect(flatten: flatten) }

            if flatten {
                self.value = result
                self.refs = []
            }

            return result
        }

        func passes(_ s: S) -> Bool {
            return (cell == s) || refs.contains{ (n, _) in n.passes(s) }
        }

        var hashValue: Int {
            return cell.hashValue
        }

        static func ==(lhs: Node, rhs: Node) -> Bool {
            return lhs.cell == rhs.cell
        }

        public var description: String {
            return cell.description
        }

        public var detailDescription: String {
            return    refs.isEmpty ? "\(cell) : \(value)" :
                  (value == .zero) ? "\(cell) -> [\(refs.map{ (n, r) in "\(r)\(n.cell)"}.joined(separator: ", "))]"
                                   : "\(cell) : {\(value) -> [\(refs.map{ (n, r) in "\(r)\(n.cell)"}.joined(separator: ", "))]}"
        }
    }

    internal func log(_ msg: @autoclosure () -> String) {
        Debug.log(msg, debug)
    }

    internal func logNodes(_ name: String, _ nodes: [S : Node]) {
        let sorted = nodes.values.filter{ !$0.isZeroNode }.sorted{ $0.cell <= $1.cell }
        log("\t\(name): {\n\t\t\(sorted.map{ $0.detailDescription }.joined(separator: ",\n\t\t"))\n\t}\n")
    }
}

public extension ChainContractor {
    public var contractedChainComplex: ChainComplex<Simplex, R> {
        typealias CC = ChainComplex<S, R>
        let chain = K.validDims.map{ (i) -> (CC.ChainBasis, CC.BoundaryMap) in

            let from = generators.filter { s in s.dim == i }
            let map  = CC.BoundaryMap { s in self.d(s) }
            return (from, map)
        }

        return CC(name: K.name, chain)
    }

    public var contractedCochainComplex: CochainComplex<Dual<Simplex>, R> {
        typealias CC = CochainComplex<Dual<S>, R>
        let chain = K.validDims.map{ (i) -> (CC.ChainBasis, CC.BoundaryMap) in
            let from = generators.filter { s in s.dim == i }
            let map  = CC.BoundaryMap { d in
                let s = d.base
                let e = R(from: (-1).pow(d.degree + 1))
                let to = self.generators.filter { s in s.dim == i + 1 }
                let vals = to.flatMap { t -> (Dual<S>, R)? in
                    let a = self.d(t)[s]
                    return (a != .zero) ? (Dual(t), e * a) : nil
                }
                return SimplicialCochain(vals)
            }
            return (from.map{ Dual($0) }, map)
        }

        return CC(name: K.name, chain)
    }

    public var homologyGroup: Homology<Simplex, R> {
        let H = Homology(contractedChainComplex)
        let map = ChainMap { s in self.g(s) }

        // factorize by: z -> f(z) -> [r]

        let factorizer = { (z: C) -> [R] in
            if z == .zero {
                return []
            }
            let i = z.anyElement!.0.degree
            return H[i].structure.factorize( self.f(z) )
        }
        return Homology(name: K.name, H, map, factorizer)
    }

    public var cohomologyGroup: Cohomology<Dual<Simplex>, R> {
        let H = Cohomology(contractedCochainComplex)
        let C = ChainComplex(K, R.self)
        let map = ChainMap { s in self.f(s) }.dualMap(domainChainComplex: C)

        // factorize by: c -> g^*(c) -> [r]

        let factorizer = { (c: SimplicialCochain<R>) -> [R] in
            if c == .zero {
                return []
            }
            let i = c.anyElement!.0.degree
            let basis = self.generators.filter{ $0.degree == i }

            // express cocycle as: (g^*)c = Σ c(g(s)) s^*

            let values = basis.flatMap { s -> (Dual<S>, R)? in
                let a = c.evaluate(self.g(s))
                return (a != .zero) ? (Dual(s), a) : nil
            }
            let cocycle = SimplicialCochain<R>(values)

            return H[i].structure.factorize( cocycle )
        }
        return Cohomology(name: K.name, H, map, factorizer)
    }
}

extension String: Error {}
