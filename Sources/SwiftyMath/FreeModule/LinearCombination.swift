//
//  LinearCombination.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/21.
//

public struct LinearCombination<A: FreeModuleGenerator, R: Ring>: FreeModule {
    public typealias BaseRing = R
    public typealias Generator = A
    
    public let elements: [A : R]
    
    public init(elements: [A : R]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }
    
    public static var symbol: String {
        "FreeMod(\(R.symbol))"
    }
}

extension LinearCombination: Multiplicative, Monoid, Ring where A: Monoid {
    public var degree: Int {
        degree_FreeModule
    }
}

extension LinearCombination where R: RealSubset {
    public var asReal: LinearCombination<A, 𝐑> {
        mapCoefficients{ $0.asReal }
    }
}

extension LinearCombination where R: ComplexSubset {
    public var asComplex: LinearCombination<A, 𝐂> {
        mapCoefficients{ $0.asComplex }
    }
}

extension LinearCombination: TensorMonoid where A: TensorMonoid {}

extension LinearCombination: Codable where A: Codable, R: Codable {}

public typealias MonoidRing<M: Monoid & FreeModuleGenerator, R: Ring> = LinearCombination<M, R>
public typealias  GroupRing<G:  Group & FreeModuleGenerator, R: Ring> = LinearCombination<G, R>
