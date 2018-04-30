//
//  ExactSequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/14.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct ExactSequence<R: EuclideanRing>: Sequence {
    public typealias Object = AbstractSimpleModuleStructure<R>
    public typealias Map    = FreeModuleHom<Int, Int, R>

    internal var objects: [Object?]
    internal var arrows : Arrows

    public init(objects: [Object?], maps: [Map?]) {
        assert(objects.count - 1 == maps.count)
        self.objects = objects
        self.arrows  = Arrows(maps)
    }

    public init(count n: Int) {
        self.init(objects: Array(repeating: nil, count: n), maps: Array(repeating: nil, count: n - 1))
    }

    public var length: Int {
        return objects.count
    }

    public subscript(i: Int) -> Object? {
        get {
            return (0 ..< length).contains(i) ? objects[i] : Object.zeroModule
        } set {
            if (0 ..< length).contains(i) {
                objects[i] = newValue
            }
        }
    }

    public func map(_ i: Int) -> Map? {
        return arrows[i].map
    }

    public func matrix(_ i: Int) -> ComputationalMatrix<R>? {
        guard
            let from = self[i],
            let to   = self[i + 1],
            let map  = arrows[i].map
            else { return nil }

        let comps = from.generators.enumerated().flatMap { (j, z) -> [MatrixComponent<R>] in
            let w = map.applied(to: z)
            let vec = to.factorize(w)
            return vec.enumerated().map{ (i, a) in (i, j, a) }
        }

        return ComputationalMatrix(rows: to.generators.count, cols: from.generators.count, components: comps)
    }

    //  The following are equivalent:
    //
    //        f0     [f1]      f2
    //    M0 ---> M1 ----> M2 ---> M3
    //
    //
    //  1) f1 = 0
    //  2) f2: injective  ( Ker(f2) = Im(f1) = 0 )
    //  3) f0: surjective ( M1 = Ker(f1) = Im(f0) )
    //

    public mutating func isZeroMap(_ i1: Int) -> Bool {
        if self.arrows[i1].isZero {
            return true
        }

        let result = { () -> Bool in
            let (i0, i2, i3) = (i1 - 1, i1 + 1, i1 + 2)

            if let M1 = self[i1], M1.isTrivial {
                return true
            }

            if let M2 = self[i2], M2.isTrivial {
                return true
            }

            if let A1 = matrix(i1), A1.isZero {
                return true
            }

            if  let M2 = self[i2], M2.isFree,
                let M3 = self[i3], M3.isFree,
                let A2 = matrix(i2), A2.eliminate().isInjective {
                return true
            }

            if  let M0 = self[i0], M0.isFree,
                let M1 = self[i1], M1.isFree,
                let A0 = matrix(i0), A0.eliminate().isSurjective {
                return true
            }

            return false
        }()

        if result {
            self.arrows[i1].isZero = true
        }

        return result
    }

    public mutating func isInjective(_ i: Int) -> Bool {
        return isZeroMap(i - 1)
    }

    public mutating func isSurjective(_ i: Int) -> Bool {
        return isZeroMap(i + 1)
    }

    public mutating func isIsomorphic(_ i: Int) -> Bool {
        return isInjective(i) && isSurjective(i)
    }

    @discardableResult
    public mutating func solve(_ i: Int, debug d: Bool = false) -> Object? {
        if let o = self[i] {
            return o
        }

        if let o = _solve(i, debug: d) {
            self[i] = o
            return o
        } else {
            return nil
        }
    }

    private mutating func _solve(_ i2: Int, debug d: Bool = false) -> Object? {

        // Aim: [M2]
        //
        //     f0      f1        f2      f3
        // M0 ---> M1 ---> [M2] ---> M3 ---> M4  (exact)
        //

        let (i0, i1, i3) = (i2 - 2, i2 - 1, i2 + 1)

        // Case 1.
        //
        //     0         0
        // M1 ---> [M2] ---> M3  ==>  M2 = Ker(0) = Im(0) = 0

        if isZeroMap(i1), isZeroMap(i2) {
            log("\(i2): trivial.", d)
            return Object.zeroModule
        }

        // Case 2.
        //
        //     0       f1        0
        // M0 ---> M1 ---> [M2] ---> M3  ==>  f1: isom

        if let M1 = self[i1], isZeroMap(i0), isZeroMap(i2) {
            log("\(i2): isom to \(i1).", d)
            arrows[i1] = Arrow.identity
            return M1
        }

        // Case 3.
        //
        //     0         f2      0
        // M1 ---> [M2] ---> M3 ---> M4  ==>  f2: isom

        if let M3 = self[i3], isZeroMap(i1), isZeroMap(i3) {
            log("\(i2): isom to \(i3).", d)
            arrows[i2] = Arrow.identity
            return M3
        }

        // General Case.
        //
        //     f0      f1        f2      f3
        // M0 ---> M1 ---> [M2] ---> M3 ---> M4  (exact)
        //
        // ==>
        //                       f2
        // 0 -> Ker(f2) ⊂  [M2] -->> Im(f2) -> 0  (exact)
        //       = Im(f1)             = Ker(f3)
        //      ~= Coker(f0)

        guard
            let M1 = self[i1], M1.isFree, // TODO concider non-free case
            let M3 = self[i3], M3.isFree,
            let A0 = matrix(i0),
            let A3 = matrix(i3)
            else {
                log("\(i2): unsolvable.", d)
                return nil
        }

        let N0 = AbstractSimpleModuleStructure.invariantFactorDecomposition(rank: M1.rank, relationMatrix: A0)
        let N1 = AbstractSimpleModuleStructure<R>(rank: A3.eliminate().nullity)

        log("\(i2): \(N0) ⊕ \(N1)", d)

        return N0 ⊕ N1
    }

    @discardableResult
    public mutating func solve(debug: Bool = false) -> [Object?] {
        return (0 ..< length).map{ i in solve(i, debug: debug) }
    }

    public func assertExactness(at i1: Int, debug d: Bool = false) {

        //     f0        f1
        // M0 ---> [M1] ---> M2

        let (i0, i2) = (i1 - 1, i1 + 1)

        guard
            let M0 = self[i0],
            let M1 = self[i1],
            let M2 = self[i2],
            let f0 = arrows[i0].map,
            let f1 = arrows[i1].map
            else {
                log("\(i1): skipped.", d)
                return
        }

        log("\(i1): \(M0) -> [\(M1)] -> \(M2)", d)

        if M1.isTrivial {
            return
        }

        // Im ⊂ Ker
        for x in M0.generators {
            let y = f0.applied(to: x)
            let z = f1.applied(to: y)

            log("\t\(x) ->\t\(y) ->\t\(z)", d)
            assert(M2.elementIsZero(z))
        }

        // Im ⊃ Ker
        // TODO
    }

    public func assertExactness(debug: Bool = false) {
        for i in 0 ..< length {
            assertExactness(at: i, debug: debug)
        }
    }

    public func makeIterator() -> AnyIterator<Object?> {
        let lazy = (0 ..< length).lazy.map{ k in self[k] }
        return AnyIterator(lazy.makeIterator())
    }

    public var description: String {
        return "ExactSequence(length: \(length))"
    }

    public var detailDescription: String {
        return "\(self.description)\n--------------------\n0\t-> "
            + objects.map{ $0.flatMap{"\($0)"} ?? "?" }.joined(separator: "\t -> ")
            + "\t-> 0"
    }

    internal struct Arrow {
        var map: Map?
        var isZero: Bool

        init(_ map: Map?, isZero: Bool = false) {
            self.map = map
            self.isZero = isZero
        }

        static var identity: Arrow {
            return Arrow(Map.identity)
        }

        static var zero: Arrow {
            return Arrow(Map.zero, isZero: true)
        }
    }

    internal struct Arrows {
        internal var arrows: [Arrow]
        internal init (_ maps: [Map?]) {
            self.arrows = maps.map{ Arrow($0) }
        }

        public subscript(i: Int) -> Arrow {
            get {
                return (0 ..< arrows.count).contains(i) ? arrows[i] : Arrow.zero
            } set {
                if (0 ..< arrows.count).contains(i) {
                    arrows[i] = newValue
                }
            }
        }
    }
}
