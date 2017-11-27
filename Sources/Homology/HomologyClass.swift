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

public struct _HomologyClass<chainType: ChainType, A: FreeModuleBase, R: EuclideanRing>: Module {
    public typealias CoeffRing = R
    public typealias Structure = _Homology<chainType, A, R>
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
        self.z = Cycle.zero
        self.factors = [:]
        self.structure = nil
    }
    
    public subscript(_ i: Int) -> Cycle {
        return factors[i] ?? Cycle.zero
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
    
    public static var zero: _HomologyClass<chainType, A, R> {
        return self.init()
    }
    
    public static func ==(a: _HomologyClass<chainType, A, R>, b: _HomologyClass<chainType, A, R>) -> Bool {
        guard let H = a.structure, let H2 = b.structure else {
            return (a.structure == nil && b.structure == nil) // when both a, b are 0.
        }
        
        assert(H.chainComplex.name == H2.chainComplex.name)
        // assert(H == H2) // this assertion is heavy
        
        if a.factors.keys == b.factors.keys {
            return a.factors.forAll { (i, z) in
                return H[i].isEquivalent(z, b[i])
            }
        } else {
            return false
        }
    }
    
    public static func +(a: _HomologyClass<chainType, A, R>, b: _HomologyClass<chainType, A, R>) -> _HomologyClass<chainType, A, R> {
        guard let H = a.structure, let H2 = b.structure else {
            return (a.structure == nil) ? b : a
        }
        
        assert(H.chainComplex.name == H2.chainComplex.name)
        // assert(H == H2) // this assertion is heavy
        
        return _HomologyClass(a.z + b.z, H)
    }
    
    public static prefix func -(a: _HomologyClass<chainType, A, R>) -> _HomologyClass<chainType, A, R> {
        return (a.structure != nil) ? _HomologyClass(-a.z, a.structure!) : a
    }
    
    public static func *(r: R, a: _HomologyClass<chainType, A, R>) -> _HomologyClass<chainType, A, R> {
        return (a.structure != nil) ? _HomologyClass(r * a.z, a.structure!) : a
    }
    
    public static func *(a: _HomologyClass<chainType, A, R>, r: R) -> _HomologyClass<chainType, A, R> {
        return (a.structure != nil) ? _HomologyClass(a.z * r, a.structure!) : a
    }
    
    public var hashValue: Int {
        return (z == Cycle.zero) ? 0 : 1
    }
    
    public var description: String {
        return (z != Cycle.zero) ? "[\(z)]" : "0"
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
