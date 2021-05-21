//
//  LinearCombination.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/21.
//

public struct LinearCombination<A: LinearCombinationGenerator, R: Ring>: LinearCombinationType {
    public typealias BaseRing = R
    public typealias Generator = A
    
    public let elements: [A : R]
    public init(elements: [A : R]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }
    
    public static var symbol: String {
        "LinComb<\(R.symbol), \(A.self)>"
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

extension LinearCombination: Codable where A: Codable, R: Codable {}
