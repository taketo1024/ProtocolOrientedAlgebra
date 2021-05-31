//
//  Array.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/07.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension Array {
    @inlinable
    static var empty: Array {
        []
    }
    
    @inlinable
    func count(where predicate: (Element) -> Bool) -> Int {
        reduce(into: 0) { predicate($1) ? $0 += 1 : () }
    }
    
    func with(_ s: (inout Array) -> Void) -> Array {
        var a = self
        s(&a)
        return a
    }
    
    func appended(_ e: Element) -> Array {
        self.with { a in a.append(e) }
    }
    
    func replaced(at i: Int, with e: Element) -> Array {
        self.with { a in a[i] = e }
    }
    
    func filled(with e: Element, upToLength n: Int) -> Array {
        let l = self.count
        return (l < n) ? self + Array(repeating: e, count: n - l) : self
    }
    
    func dropLast(while predicate: (Element) -> Bool) -> Array {
        self.with { result in
            while let e = result.popLast() {
                if !predicate(e) {
                    result.append(e)
                    return
                }
            }
        }
    }
    
    func merging(_ other: Array, filledWith e: Element, mergedBy f: (Element, Element) -> Element) -> Array {
        let l = Swift.max(self.count, other.count)
        let (a, b) = (self.filled(with: e, upToLength: l), other.filled(with: e, upToLength: l))
        return zip(a, b).map(f)
    }
    
    func takeEven() -> Array {
        self.enumerated().filter{ $0.offset.isEven }.map{ $0.element }
    }
    
    func takeOdd() -> Array {
        self.enumerated().filter{ $0.offset.isOdd  }.map{ $0.element }
    }
    
    static func *(a: Array, n: Int) -> Array {
        (0 ..< n).flatMap { _ in a }
    }
}

extension Array where Element: Equatable {
    @discardableResult
    public mutating func findAndRemove(element: Element) -> Bool {
        if let i = firstIndex(of: element) {
            remove(at: i)
            return true
        } else {
            return false
        }
    }
}

extension Array: Comparable where Element: Comparable {
    public static func < (lhs: Array, rhs: Array) -> Bool {
        lhs.lexicographicallyPrecedes(rhs)
    }
}

extension Array {
    public func parallelForEach(body: @escaping  (Element) -> Void ) {
        DispatchQueue.concurrentPerform(iterations: count) { i in
            body(self[i])
        }
    }
    
    public func parallelMap<T>(transform: (Element) -> T) -> [T] {
        var result = ContiguousArray<T?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: buffer.count) { idx in
                buffer[idx] = transform(self[idx])
            }
            return buffer.map { $0! }
        }
    }
    
    public func parallelFlatMap<T>(transform: @escaping (Element) -> [T] ) -> [T] {
        parallelMap(transform: transform).flatMap { $0 }
    }
    
    public func parallelCompactMap<T>(transform: @escaping (Element) -> T? ) -> [T] {
        parallelMap(transform: transform).compactMap { $0 }
    }
    
    public func parallelFilter(predicate: @escaping  (Element) -> Bool ) -> Self {
        parallelCompactMap { e in predicate(e) ? e : nil }
    }
}
