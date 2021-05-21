//
//  TensorGenerator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/07/09.
//

public struct TensorGenerator<A, B>: LinearCombinationGenerator where A: LinearCombinationGenerator, B: LinearCombinationGenerator {
    public let left : A
    public let right: B
    
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

extension LinearCombinationGenerator {
    public static func ⊗<Other: LinearCombinationGenerator>(_ a: Self, _ b: Other) -> TensorGenerator<Self, Other> {
        .init(a, b)
    }
}

public protocol TensorMonoid {
    static func ⊗(lhs: Self, rhs: Self) -> Self
}

public struct MultiTensorGenerator<A: LinearCombinationGenerator>: LinearCombinationGenerator, TensorMonoid {
    public let factors: [A]
    public init(_ factors: [A]) {
        self.factors = factors
    }
    
    public init(_ factors: A ...) {
        self.init(factors)
    }
    
    public static var identity: Self {
        .init([])
    }
    
    public var degree: Int {
        factors.sum { $0.degree }
    }
    
    public static func ⊗(t1: Self, t2: Self) -> Self {
        .init(t1.factors + t2.factors)
    }
    
    public static func < (t1: Self, t2: Self) -> Bool {
        t1.factors < t2.factors
    }
    
    public var description: String {
        return factors.map{ $0.description }.joined(separator: "⊗")
    }
}

extension LinearCombinationType where Generator: TensorMonoid {
    public static func ⊗(lhs: Self, rhs: Self) -> Self {
        return lhs.elements.sum { (t1, r1) in
            rhs.elements.sum { (t2, r2) in
                let r = r1 * r2
                let t = t1 ⊗ t2
                return r * .init(t)
            }
        }
    }
}

extension LinearCombination: TensorMonoid where A: TensorMonoid {}

public func MultiTensorHom<A, R>(from f: ModuleEnd<LinearCombination<R, A>>, inputIndex: Int, outputIndex: Int) -> ModuleEnd<LinearCombination<R, MultiTensorGenerator<A>>> {
    .linearlyExtend { t in
        let x = t.factors[inputIndex]
        return f(x).mapGenerators { y in
            MultiTensorGenerator(t.factors.with { factors in
                factors.remove(at: inputIndex)
                factors.insert(y, at: outputIndex)
            })
        }
    }
}

public func MultiTensorHom<A, R>(from f: ModuleHom<LinearCombination<R, TensorGenerator<A, A>>, LinearCombination<R, A>>, inputIndices: (Int, Int), outputIndex: Int) -> ModuleEnd<LinearCombination<R, MultiTensorGenerator<A>>> {
    .linearlyExtend { t in
        let (x1, x2) = (t.factors[inputIndices.0], t.factors[inputIndices.1])
        return f(x1 ⊗ x2).mapGenerators { y in
            MultiTensorGenerator(t.factors.with { factors in
                factors.remove(at: inputIndices.1)
                factors.remove(at: inputIndices.0)
                factors.insert(y, at: outputIndex)
            })
        }
    }
}

public func MultiTensorHom<A, R>(from f: ModuleHom<LinearCombination<R, A>, LinearCombination<R, TensorGenerator<A, A>>>, inputIndex: Int, outputIndices: (Int, Int)) -> ModuleEnd<LinearCombination<R, MultiTensorGenerator<A>>> {
    .linearlyExtend { t in
        let x = t.factors[inputIndex]
        return f(x).mapGenerators { y in
            MultiTensorGenerator(t.factors.with { factors in
                factors.remove(at: inputIndex)
                factors.insert(y.factors.0, at: outputIndices.0)
                factors.insert(y.factors.1, at: outputIndices.1)
            })
        }
    }
}

extension MultiTensorGenerator: Codable where A: Codable {}
