//
//  LinkSpliceState.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

public struct LinkSpliceState: Equatable, Comparable, Hashable, CustomStringConvertible {
    public let bits: [UInt8]
    public init(_ bits: [UInt8]) {
        self.bits = bits
    }

    public var length: Int {
        return bits.count
    }

    public var degree: Int {
        return bits.count { $0 == 1 }
    }

    public var next: [(sign: Int, state: LinkSpliceState)] {
        return (0 ..< length).compactMap { i -> (Int, LinkSpliceState)? in
            if bits[i] == 0 {
                let sgn = (-1).pow( bits[0 ..< i].count{ $0 == 1 } )
                let next = bits.replaced(at: i, with: 1)
                return (sgn, LinkSpliceState(next))
            } else {
                return nil
            }
        }
    }

    public static func all(_ n: Int) -> [LinkSpliceState] {
        return (0 ..< n).reduce([[]]) { (res, _) -> [[UInt8]] in
            res.map{ $0 + [0] } + res.map{ $0 + [1] }
        }.map{ LinkSpliceState($0) }.sorted()
    }

    public static func ==(a: LinkSpliceState, b: LinkSpliceState) -> Bool {
        return a.bits == b.bits
    }

    public static func <(a: LinkSpliceState, b: LinkSpliceState) -> Bool {
        return a.degree < b.degree || (a.degree == b.degree && b.bits.lexicographicallyPrecedes(a.bits))
    }

    public var hashValue: Int {
        return bits.reduce(0) { (res, b) in 2 &* res &+ Int(b) }
    }

    public var description: String {
        return bits.map{ "\($0)" }.joined()
    }
}

public extension Link {
    public func spliced(by state: LinkSpliceState) -> Link {
        var L = self.copy()
        for (i, b) in state.bits.enumerated() {
            if b == 0 {
                L.spliceA(at: i)
            } else {
                L.spliceB(at: i)
            }
        }
        return L
    }
}

extension LinkSpliceState: Codable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        self.bits = try c.decode([UInt8].self)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(bits)
    }
}
