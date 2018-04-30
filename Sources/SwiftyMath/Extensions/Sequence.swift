//
//  Sequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public extension Sequence {
    public func toArray() -> [Element] {
        return Array(self)
    }
    
    public var anyElement: Element? {
        return first { _ in true }
    }
    
    public func forAll(_ f: (Element) -> Bool) -> Bool {
        for e in self {
            if !f(e) {
                return false
            }
        }
        return true
    }
    
    public func count(where predicate: (Element) -> Bool) -> Int {
        return self.lazy.filter(predicate).count
    }
    
    public func sorted<C: Comparable>(by indexer: (Element) -> C) -> [Element] {
        return self.sorted{ (e1, e2) in indexer(e1) < indexer(e2) }
    }
    
    public func group<U: Hashable>(by keyGenerator: (Element) -> U) -> [U: [Element]] {
        return Dictionary(grouping: self, by: keyGenerator)
    }
    
    public func allCombinations<S: Sequence>(with s2: S) -> [(Self.Element, S.Element)] {
        typealias X = Self.Element
        typealias Y = S.Element
        return self.flatMap{ (x) -> [(X, Y)] in
            s2.map{ (y) -> (X, Y) in (x, y) }
        }
    }
}

public extension Sequence where Element: Hashable {
    public var isUnique: Bool {
        var alreadyAdded = Set<Element>()
        return self.forAll { alreadyAdded.insert($0).inserted }
    }
    
    public func unique() -> [Element] {
        var alreadyAdded = Set<Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
    
    public func subtract(_ b: Self) -> [Element] {
        let set = Set(b)
        return self.filter{ !set.contains($0) }
    }
    
    public func countMultiplicities() -> [Element : Int] {
        return self.group{ $0 }.mapValues{ $0.count }
    }
}

public extension Sequence where Element: AdditiveGroup {
    @_inlineable public func sumAll() -> Element {
        return sum{ $0 }
    }
}

public extension Sequence {
    @_inlineable public func sum<G: AdditiveGroup>(mapping f: (Element) -> G) -> G {
        return self.reduce(.zero){ $0 + f($1)}
    }
}

public extension Sequence where Element: Monoid {
    @_inlineable public func multiplyAll() -> Element {
        return multiply{ $0 }
    }
}

public extension Sequence {
    @_inlineable public func multiply<G: Monoid>(mapping f: (Element) -> G) -> G {
        return self.reduce(.identity){ $0 * f($1) }
    }
}
