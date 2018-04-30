//
//  GroupStructure.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/12.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public class GroupStructure: AlgebraicStructure {
    public static func ==(a: GroupStructure, b: GroupStructure) -> Bool {
        fatalError("implement in subclass")
    }
    
    public var description: String {
        return "\(type(of: self))"
    }
}

public class SubgroupStructure<G: Group>: GroupStructure {
    public typealias Base = G
    
    public func contains(_ g: G) -> Bool {
        fatalError("implement in subclass")
    }
    
    public static func ==(a: SubgroupStructure<G>, b: SubgroupStructure<G>) -> Bool {
        fatalError("implement in subclass")
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
