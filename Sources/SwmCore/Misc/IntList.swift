//
//  File.swift
//  
//
//  Created by Taketo Sano on 2021/05/18.
//

public struct IntList<n: SizeType>: AdditiveGroup, Sequence, ExpressibleByArrayLiteral, Comparable, Hashable, Codable {
    public typealias ArrayLiteralElement = Int
    
    private let elements: [Int]
    
    public init(_ indices: [Int]) {
        if n.isFixed {
            assert(indices.count == n.intValue)
            self.elements = indices
        } else {
            self.elements = indices.dropLast{ $0 == 0 }
        }
    }
    
    public init(_ indices: Int...) {
        self.init(indices)
    }
    
    public init(arrayLiteral elements: Int...) {
        self.init(elements)
    }
    
    public subscript(_ i: Int) -> Int {
        if n.isFixed {
            return elements[i]
        } else {
            return elements.indices.contains(i) ? elements[i] : 0
        }
    }
    
    public var total: Int {
        elements.sum()
    }
    
    public func makeIterator() -> IndexingIterator<[Int]> {
        elements.makeIterator()
    }
    
    public static var isFixed: Bool {
        n.isFixed
    }
    
    public static var length: Int {
        n.intValue
    }
    
    public static var zero: IntList<n> {
        n.isFixed ? .init([0] * n.intValue) : .init([])
    }
    
    public static func ==(c1: Self, c2: Self) -> Bool {
        c1.elements == c2.elements
    }

    public static func +(c1: Self, c2: Self) -> Self {
        if n.isFixed {
            return .init( c1.elements.merging(c2.elements, mergedBy: +) )
        } else {
            return .init( c1.elements.merging(c2.elements, filledWith: 0, mergedBy: +) )
        }
    }
    
    public static prefix func -(_ c: Self) -> Self {
        .init( c.elements.map{ -$0 } )
    }

    public static func < (c1: Self, c2: Self) -> Bool {
        (c1 != c2) && (c2 - c1).elements.allSatisfy{ $0 >= 0 }
    }
    
    public var description: String {
        "(\( elements.map{ $0.description }.joined(separator: ", ") ))"
    }
}

extension IntList where n == _2 {
    public init(_ indices: (Int, Int)) {
        self.init([indices.0, indices.1])
    }
    
    public var tuple: (Int, Int) {
        (self[0], self[1])
    }
}

extension IntList where n == _3 {
    public init(_ indices: (Int, Int, Int)) {
        self.init([indices.0, indices.1, indices.2])
    }
    
    public var triple: (Int, Int, Int) {
        (self[0], self[1], self[2])
    }
}
