//
//  DynamicType.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/04.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// A `Structure` instance expresses a mathematical structure that is determined dynamically.
// Used when we want a 'dynamic-type', where Swift-types are strictly static.
//
// * All finite subgroups of a finite (static) group.
// * The invariant factor decomposition of a given f.g. module.
// * The Homology group of a given SimplicialComplex.

public protocol Structure: class, Equatable, CustomStringConvertible { }

public extension Structure {
    public var detailDescription: String {
        return description
    }
}

public class SubgroupStructure<G: Group>: Structure {
    public typealias Base = G

    public func contains(_ g: G) -> Bool {
        fatalError("implement in subclass")
    }

    public static func ==(a: SubgroupStructure<G>, b: SubgroupStructure<G>) -> Bool {
        fatalError("implement in subclass")
    }

    public var description: String {
        return "\(type(of: self))"
    }
}

public final class FiniteSubgroupStructure<G: Group>: SubgroupStructure<G> {
    public let allElements: Set<G>

    public init<S: Sequence>(allElements: S) where S.Element == G {
        self.allElements = Set(allElements)
        super.init()
    }

    public var countElements: Int {
        return allElements.count
    }

    public override func contains(_ g: G) -> Bool {
        return allElements.contains(g)
    }

    public static func ==(a: FiniteSubgroupStructure<G>, b: FiniteSubgroupStructure<G>) -> Bool {
        return a.allElements == b.allElements
    }

    public override var description: String {
        return "{\(Array(allElements).map{"\($0)"}.joined(separator: ", "))}"
    }
}
