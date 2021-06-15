//
//  RandomAccessCollection.swift
//  
//
//  Created by Taketo Sano on 2021/06/15.
//

import Foundation

extension RandomAccessCollection where Element: Comparable {
    @inlinable
    public func binarySearchIndex(_ element: Element) -> Index? {
        let index = partitioningIndex(where: { $0 >= element })
        let found = index != endIndex && self[index] == element
        return found ? index : nil
    }
}

extension RandomAccessCollection {
    @inlinable
    public func binarySearch<T: Comparable>(elementWithId id: T, by f: (Element) -> T) -> Element? {
        let index = partitioningIndex(where: { f($0) >= id })
        let found = index != endIndex && f(self[index]) == id
        return found ? self[index] : nil
    }
}
