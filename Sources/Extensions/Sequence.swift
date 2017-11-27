//
//  Sequence.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension Sequence {
    var anyElement: Element? {
        return first { _ in true }
    }
    
    func forAll(_ f: (Element) -> Bool) -> Bool {
        for e in self {
            if !f(e) {
                return false
            }
        }
        return true
    }
    
    func exists(_ f: (Element) -> Bool) -> Bool {
        return contains(where: f)
    }
    
    func toArray() -> [Element] {
        return Array(self)
    }
}

public extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var alreadyAdded = Set<Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
    
    func subtract(_ b: Self) -> [Element] {
        let set = Set(b)
        return self.filter{ !set.contains($0) }
    }
}

public extension Sequence {
    func group<U: Hashable>(by keyGenerator: (Element) -> U) -> [U: [Element]] {
        return Dictionary(grouping: self, by: keyGenerator)
    }
    
    func allCombinations<S: Sequence>(with s2: S) -> [(Self.Element, S.Element)] {
        typealias X = Self.Element
        typealias Y = S.Element
        return self.flatMap{ (x) -> [(X, Y)] in
            s2.map{ (y) -> (X, Y) in (x, y) }
        }
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
