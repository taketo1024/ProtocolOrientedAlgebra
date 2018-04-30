//
//  GroupRing.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/10.
//

public struct GroupRing<G: Group, R: Ring>: Ring {
    private let elements: [G : R]
    public init(_ elements: [G : R]) {
        self.elements = elements
    }
    
    public init(_ elements: [(G, R)]) {
        self.init(Dictionary(pairs: elements))
    }
    
    public subscript(g: G) -> R {
        return elements[g, default: .zero]
    }
    
    public static prefix func - (a: GroupRing<G, R>) -> GroupRing<G, R> {
        return GroupRing(a.elements.mapValues{ -$0 })
    }
    
    public init(from n: 𝐙) {
        self.init([.identity : R(from: n)])
    }
    
    public var inverse: GroupRing<G, R>? {
        fatalError()
    }
    
    public static func + (a: GroupRing<G, R>, b: GroupRing<G, R>) -> GroupRing<G, R> {
        let keys = Set(a.elements.keys).union(b.elements.keys)
        return GroupRing(Dictionary(keys: keys) { g in
            a[g] + b[g]
        })
    }
    
    public static func * (a: GroupRing<G, R>, b: GroupRing<G, R>) -> GroupRing<G, R> {
        var elements = [G : R]()
        for (g1, g2) in a.elements.keys.allCombinations(with: b.elements.keys) {
            let g = g1 * g2
            elements[g] = elements[g, default: .zero] + a[g1] * b[g2]
        }
        return GroupRing(elements)
    }
    
    public var hashValue: Int {
        return 0 // TODO
    }
    
    public var description: String {
        return elements.map{ (g, a) in "\(a)(\(g))"}.joined(separator: " + ")
    }
    
    public static var symbol: String {
        return "\(R.symbol)[\(G.symbol)]"
    }
}
