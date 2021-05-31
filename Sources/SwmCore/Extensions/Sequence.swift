//
//  Sequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Algorithms

public extension Sequence {
    @inlinable
    var isEmpty: Bool {
        anyElement == nil
    }
    
    @inlinable
    var anyElement: Element? {
        first { _ in true }
    }
    
    @inlinable
    var count: Int {
        count { _ in true }
    }
    
    @inlinable
    func count(where predicate: (Element) -> Bool) -> Int {
        self.reduce(into: 0) { (c, x) in
            if predicate(x) { c += 1 }
        }
    }
    
    @inlinable
    func exclude(_ isExcluded: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        try self.filter{ try !isExcluded($0) }
    }
    
    func reduce<Result>(_ initialResult: Result, while shouldContinue: (Result, Self.Element) -> Bool, _ nextPartialResult: (Result, Self.Element) throws -> Result) rethrows -> Result {
        var res = initialResult
        for e in self {
            if !shouldContinue(res, e) { break }
            res = try nextPartialResult(res, e)
        }
        return res
    }
    
    func reduce<Result>(into initialResult: Result, while shouldContinue: (Result, Self.Element) -> Bool, _ updateAccumulatingResult: (inout Result, Self.Element) throws -> ()) rethrows -> Result {
        var res = initialResult
        for e in self {
            if !shouldContinue(res, e) { break }
            try updateAccumulatingResult(&res, e)
        }
        return res
    }
    
    @inlinable
    func sorted<C: Comparable>(by indexer: (Element) -> C) -> [Element] {
        self.sorted{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
    @inlinable
    func max<C: Comparable>(by indexer: (Element) -> C) -> Element? {
        self.max{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
    @inlinable
    func min<C: Comparable>(by indexer: (Element) -> C) -> Element? {
        self.min{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
    @inlinable
    func group<U: Hashable>(by keyGenerator: (Element) -> U) -> [U: [Element]] {
        Dictionary(grouping: self, by: keyGenerator)
    }
    
    func split(by predicate: (Element) -> Bool) -> ([Element], [Element]) {
        var T: [Element] = []
        var F: [Element] = []
        for e in self {
            if predicate(e) {
                T.append(e)
            } else {
                F.append(e)
            }
        }
        return (T, F)
    }
    
    func toArray() -> [Element] {
        Array(self)
    }
    
    func toDictionary() -> [Int: Element] {
        Dictionary(self.enumerated().map{ (i, a) in (i, a) } )
    }
    
    static func *<S: Sequence>(s1: Self, s2: S) -> Product2<Self, S> {
        product(s1, s2)
    }
}

public extension Sequence where Element: Hashable {
    var isUnique: Bool {
        var bucket = Set<Element>()
        return self.allSatisfy{ bucket.insert($0).inserted }
    }
    
    func unique() -> [Element] {
        var bucket = Set<Element>()
        return self.filter { bucket.insert($0).inserted }
    }
    
    func subtract(_ set: Set<Element>) -> [Element] {
        return self.filter{ !set.contains($0) }
    }
    
    func isDisjoint<S: Sequence>(with other: S) -> Bool where S.Element == Element {
        Set(self).isDisjoint(with: other)
    }
    
    func countMultiplicities() -> [Element : Int] {
        self.group{ $0 }.mapValues{ $0.count }
    }
    
    func makeIndexer() -> (Element) -> Int? {
        let dict = Dictionary(self.enumerated().map{ ($1, $0) })
        return { dict[$0] }
    }
}

public extension Sequence where Element: Comparable {
    var closureRange: ClosedRange<Element>? {
        if let m = self.min(), let M = self.max() {
            return m ... M
        } else {
            return nil
        }
    }
}
