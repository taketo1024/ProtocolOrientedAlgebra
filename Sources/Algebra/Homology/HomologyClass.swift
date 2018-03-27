//
//  HomologyClass.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/07/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// A class representing the algebraic Homology group.
// Each instance corresponds to a homology-class of the given cycle,
// that lives in the homology-group defined by the given structure.

public typealias   HomologyClass<A: FreeModuleBase, R: EuclideanRing> = _HomologyClass<Descending, A, R>
public typealias CohomologyClass<A: FreeModuleBase, R: EuclideanRing> = _HomologyClass<Ascending, A, R>

public struct _HomologyClass<T: ChainType, A: FreeModuleBase, R: EuclideanRing>: Module {
    public typealias CoeffRing = R
    public typealias Structure = _Homology<T, A, R>
    public typealias Cycle = Structure.Cycle // = FreeModule<A, R>

    private let z: Cycle
    private let factors: [Int : Cycle]
    public  let structure: Structure?

    public init(_ z: Cycle, _ H: Structure) {
        self.z = z
        self.factors = z.group { (a, _) in a.degree }
                        .mapValues{ Cycle($0) }
        self.structure = H
    }

    private init() {
        self.z = .zero
        self.factors = [:]
        self.structure = nil
    }

    public subscript(_ i: Int) -> _HomologyClass<T, A, R> {
        return factors[i].map{ _HomologyClass($0, structure!) } ?? .zero
    }

    public var representative: Cycle {
        return z
    }

    public var offset: Int {
        return structure?.offset ?? 0
    }

    public var isHomogeneous: Bool {
        if let i = z.anyElement?.0.degree {
            return z.forAll{ (a, _) in a.degree == i }
        } else {
            return true
        }
    }

    public var homogeneousDegree: Int {
        return z.anyElement?.0.degree ?? 0
    }

    public static var zero: _HomologyClass<T, A, R> {
        return self.init()
    }

    public var isZero: Bool {
        return self == _HomologyClass<T, A, R>.zero
    }

    public static func ==(a: _HomologyClass<T, A, R>, b: _HomologyClass<T, A, R>) -> Bool {
        switch (a.structure, b.structure) {
        case let (H1?, H2?):

            assert(H1 == H2)

            if a.factors.keys == b.factors.keys {
                return a.factors.forAll { (i, z) in
                    let w = b.factors[i] ?? Cycle.zero
                    return H1[i].cyclesAreHomologous(z, w)
                }
            } else {
                return false
            }
        case let (H1?, nil):
            return a.factors.forAll { (i, z) in H1[i].cycleIsNullHomologous(z) }
        case let (nil, H2?):
            return b.factors.forAll { (i, z) in H2[i].cycleIsNullHomologous(z) }
        default:
            return true
        }
    }

    public static func +(a: _HomologyClass<T, A, R>, b: _HomologyClass<T, A, R>) -> _HomologyClass<T, A, R> {
        guard let H1 = a.structure, let H2 = b.structure else {
            return (a.structure == nil) ? b : a
        }

        assert(H1 == H2)
        return _HomologyClass(a.z + b.z, H1)
    }

    public static prefix func -(a: _HomologyClass<T, A, R>) -> _HomologyClass<T, A, R> {
        return (a.structure != nil) ? _HomologyClass(-a.z, a.structure!) : a
    }

    public static func *(r: R, a: _HomologyClass<T, A, R>) -> _HomologyClass<T, A, R> {
        return (a.structure != nil) ? _HomologyClass(r * a.z, a.structure!) : a
    }

    public static func *(a: _HomologyClass<T, A, R>, r: R) -> _HomologyClass<T, A, R> {
        return (a.structure != nil) ? _HomologyClass(a.z * r, a.structure!) : a
    }

    public var hashValue: Int {
        return z == .zero ? 0 : 1
    }

    public var description: String {
        return z != .zero ? "[\(z)]" : "0"
    }

    public var detailDescription: String {
        if let s = structure {
            return description + " in \(s)"
        } else {
            return "0"
        }
    }
}

public func pair<A, R>(_ x: HomologyClass<A, R>, _ y: CohomologyClass<Dual<A>, R>) -> R {
    guard let H = x.structure, let cH = y.structure else {
        return .zero
    }

    // TODO must assert that H, cH is a valid pair.

    return x.representative.evaluate(y.representative)
}

public func pair<A, R>(_ y: CohomologyClass<Dual<A>, R>, _ x: HomologyClass<A, R>) -> R {
    return pair(x, y)
}

public extension FreeModule where R: EuclideanRing {
    public func asHomologyClass(of H: Homology<A, R>) -> HomologyClass<A, R> {
        let x = HomologyClass(self, H)
        return x
    }

    public func asCohomologyClass(of H: Cohomology<A, R>) -> CohomologyClass<A, R> {
        return CohomologyClass(self, H)
    }
}
