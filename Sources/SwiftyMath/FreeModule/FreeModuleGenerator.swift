//
//  FreeModuleGenerator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/07/09.
//

import Foundation

public protocol FreeModuleGenerator: Hashable, Comparable, CustomStringConvertible {
    var degree: Int { get }
}

public extension FreeModuleGenerator {
    var degree: Int { return 1 }
}

public struct TensorGenerator<A, B>: FreeModuleGenerator where A: FreeModuleGenerator, B: FreeModuleGenerator {
    private let left: A
    private let right: B
    
    public init(_ a: A, _ b: B) {
        self.left = a
        self.right = b
    }
    
    public var factors: (A, B) {
        return (left, right)
    }
    
    public var degree: Int {
        return left.degree + right.degree
    }
    
    public static func < (a: TensorGenerator<A, B>, b: TensorGenerator<A, B>) -> Bool {
        return [a.left.degree, a.right.degree] < [b.left.degree, b.right.degree]
    }
    
    public var description: String {
        return "\(left.description)⊗\(right.description)"
    }
}
