//
//  Sequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public extension Sequence {
    var isEmpty: Bool {
        anyElement == nil
    }
    
    var anyElement: Element? {
        first { _ in true }
    }
    
    var count: Int {
        count { _ in true }
    }
    
    func count(where predicate: (Element) -> Bool) -> Int {
        self.reduce(into: 0) { (c, x) in
            if predicate(x) { c += 1 }
        }
    }
    
    func exclude(_ isExcluded: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        try self.filter{ try !isExcluded($0) }
    }
    
    func sorted<C: Comparable>(by indexer: (Element) -> C) -> [Element] {
        self.sorted{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
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
    
    var asDictionary: [Int: Element] {
        Dictionary(pairs: self.enumerated().map{ (i, a) in (i, a) } )
    }
    
    static func *<S: Sequence>(s1: Self, s2: S) -> AnySequence<(Self.Element, S.Element)> {
        typealias X = Self.Element
        typealias Y = S.Element
        return AnySequence(s1.lazy.flatMap{ (x) -> [(X, Y)] in
            s2.lazy.map{ (y) -> (X, Y) in (x, y) }
        })
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
    
    func subtract(_ b: Self) -> [Element] {
        let set = Set(b)
        return self.filter{ !set.contains($0) }
    }
    
    func isDisjoint<S: Sequence>(with other: S) -> Bool where S.Element == Element {
        Set(self).isDisjoint(with: other)
    }
    
    func countMultiplicities() -> [Element : Int] {
        self.group{ $0 }.mapValues{ $0.count }
    }
}

public extension Sequence where Element: Comparable {
    var range: ClosedRange<Element>? {
        if let m = self.min(), let M = self.max() {
            return m ... M
        } else {
            return nil
        }
    }
}
