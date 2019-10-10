//
//  FreeModuleGenerator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/07/09.
//

public protocol FreeModuleGenerator: Hashable, Comparable, CustomStringConvertible {
    var degree: Int { get }
}

public extension FreeModuleGenerator {
    var degree: Int { 1 }
}

public struct TensorGenerator<A, B>: FreeModuleGenerator where A: FreeModuleGenerator, B: FreeModuleGenerator {
    private let left: A
    private let right: B
    
    public init(_ a: A, _ b: B) {
        self.left = a
        self.right = b
    }
    
    public var factors: (A, B) {
        (left, right)
    }
    
    public var degree: Int {
        left.degree + right.degree
    }
    
    public static func < (a: Self, b: Self) -> Bool {
        [a.left.degree, a.right.degree] < [b.left.degree, b.right.degree]
    }
    
    public var description: String {
        "\(left.description)⊗\(right.description)"
    }
}

public func ⊗<A: FreeModuleGenerator, B: FreeModuleGenerator>(_ a: A, _ b: B) -> TensorGenerator<A, B> {
    .init(a, b)
}
