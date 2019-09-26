//
//  GroupRing.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/10.
//

public struct GroupRing<G: Group & Hashable, R: Ring>: Ring {
    private let elements: [G : R]
    public init(_ elements: [G : R]) {
        self.elements = elements
    }
    
    public init(_ elements: [(G, R)]) {
        self.init(Dictionary(pairs: elements))
    }
    
    public subscript(g: G) -> R {
        elements[g, default: .zero]
    }
    
    public static prefix func - (a: GroupRing) -> GroupRing {
        GroupRing(a.elements.mapValues{ -$0 })
    }
    
    public init(from n: 𝐙) {
        self.init([.identity : R(from: n)])
    }
    
    public var inverse: GroupRing? {
        fatalError()
    }
    
    public static func + (a: GroupRing, b: GroupRing) -> GroupRing {
        let keys = Set(a.elements.keys).union(b.elements.keys)
        return GroupRing(Dictionary(keys: keys) { g in
            a[g] + b[g]
        })
    }
    
    public static func * (a: GroupRing, b: GroupRing) -> GroupRing {
        var elements = [G : R]()
        for (g1, g2) in (a.elements.keys * b.elements.keys) {
            let g = g1 * g2
            elements[g] = elements[g, default: .zero] + a[g1] * b[g2]
        }
        return GroupRing(elements)
    }
    
    public var description: String {
        elements.map{ (g, a) in "\(a)(\(g))"}.joined(separator: " + ")
    }
    
    public static var symbol: String {
        "\(R.symbol)[\(G.symbol)]"
    }
}
