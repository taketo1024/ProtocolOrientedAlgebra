//
//  Array.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/07.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension Array {
    static var empty: [Element] {
        return []
    }
    
    func appended(_ e: Element) -> [Element] {
        var a = self
        a.append(e)
        return a
    }
    
    func replaced(at i: Int, with e: Element) -> [Element] {
        var a = self
        a[i] = e
        return a
    }
    
    func moved(elementAt i: Int, to j: Int) -> [Element] {
        var a = self
        let e = a.remove(at: i)
        a.insert(e, at: j)
        return a
    }
    
    func removed(at i: Int) -> [Element] {
        var a = self
        a.remove(at: i)
        return a
    }
    
    mutating func dropLast(while predicate: (Element) -> Bool) {
        while let e = popLast() {
            if !predicate(e) {
                append(e)
                return
            }
        }
    }
    
    func droppedLast(while predicate: (Element) -> Bool) -> [Element] {
        var copy = self
        copy.dropLast(while: predicate)
        return copy
    }
    
    func repeated(_ count: Int) -> [Element] {
        return (Array<[Element]>(repeating: self, count: count)).flatMap{ $0 }
    }
    
    func takeEven() -> [Element] {
        return self.enumerated().filter{ $0.offset.isEven }.map{ $0.element }
    }
    
    func takeOdd() -> [Element] {
        return self.enumerated().filter{ $0.offset.isOdd  }.map{ $0.element }
    }

    func toDictionary() -> [Index: Element] {
        return Dictionary(pairs: self.enumerated().map{ (i, a) in (i, a) })
    }
}

extension Array where Element: Equatable {
    @discardableResult
    public mutating func remove(element: Element) -> Bool {
        if let i = firstIndex(of: element) {
            remove(at: i)
            return true
        } else {
            return false
        }
    }
}

extension Array: Comparable where Element: Comparable {
    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        return lhs.lexicographicallyPrecedes(rhs)
    }
}

extension Array where Element: Hashable {
    public func indexer() -> (Element) -> Int? {
        let dict = Dictionary(pairs: self.enumerated().map{ ($1, $0) })
        return { dict[$0] }
    }
}
