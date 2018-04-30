//
//  AlternatingGroup.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct AlternatingGroup<n: _Int>: Subgroup, FiniteSetType {
    public typealias Super = SymmetricGroup<n>

    private let g: Super

    public init(_ g: Super) {
        self.g = g
    }

    public init(_ p: Permutation) {
        self.init( Super(p) )
    }

    public init(_ dict: [Int: Int]) {
        self.init( Super(dict) )
    }

    public init(cyclic: Int...) {
        self.init( Super(cyclic: cyclic) )
    }

    public var asSuper: Super {
        return g
    }

    public static func contains(_ g: Super) -> Bool {
        return g.signature == 1
    }

    public static var allElements: [AlternatingGroup<n>] {
        return Super.allElements.filter{ $0.signature == 1 }.map{ AlternatingGroup($0) }
    }

    public static var countElements: Int {
        return n.intValue.factorial / 2
    }

    public static var symbol: String {
        return "A_\(n.intValue)"
    }
}
