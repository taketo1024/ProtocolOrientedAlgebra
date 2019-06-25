//
//  LinkedList.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/06/25.
//

import Foundation

public final class LinkedList<T>: Sequence {
    public var value: T
    public var next: LinkedList<T>?
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
    
    public struct Iterator: IteratorProtocol {
        private var current: LinkedList<T>?
        fileprivate init(_ start: LinkedList<T>) {
            current = start
        }
        
        public mutating func next() -> LinkedList<T>? {
            defer {
                current = current?.next
            }
            return current
        }
    }
}

