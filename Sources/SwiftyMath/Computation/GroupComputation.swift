//
//  GroupComputation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/05/29.
//

import Foundation

public extension Group {
    static func formsSubgroup<S: Sequence>(_ elements: S) -> Bool where S.Element == Self {
        let list = Array(elements)
        let n = list.count
        
        // check ^-1 closed
        for g in list {
            if !elements.contains(g.inverse) {
                return false
            }
        }
        
        // check *-closed
        let combis = n.choose(2)
        for c in combis {
            let (g, h) = (list[c[0]], list[c[1]])
            if !elements.contains(g * h) {
                return false
            }
            if !elements.contains(h * g) {
                return false
            }
        }
        
        return true
    }
}

public extension Group where Self: FiniteSetType {
    static func cyclicSubgroup(generator: Self) -> FiniteSubgroupStructure<Self> {
        var g = generator
        var set = Set([identity])
        while !set.contains(g) {
            set.insert(g)
            g = g * g
        }
        return FiniteSubgroupStructure(allElements: set)
    }
    
    static var allCyclicSubgroups: [FiniteSubgroupStructure<Self>] {
        return allElements.map{ cyclicSubgroup(generator: $0) }.sorted{ $0.countElements < $1.countElements }
    }
    
    static var allSubgroups: [FiniteSubgroupStructure<Self>] {
        let n = countElements
        if n == 1 {
            return [cyclicSubgroup(generator: identity)]
        }
        
        let cyclics = allCyclicSubgroups
        var unions: Set<Set<Self>> = Set()
        unions.insert(Set([identity]))
        
        for k in 2...cyclics.count {
            n.choose(k).forEach { c in
                let union: Set<Self> = c.map{ cyclics[$0] }.reduce([]){ $0.union($1.allElements) }
                
                // TODO improve algorithm
                if !unions.contains(union) && (n % union.count == 0) && formsSubgroup(union) {
                    unions.insert(union)
                }
            }
        }
        
        return unions
            .sorted{ $0.count < $1.count }
            .map{ FiniteSubgroupStructure(allElements: $0) }
    }
}

