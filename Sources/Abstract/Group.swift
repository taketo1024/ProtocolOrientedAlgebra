import Foundation

public protocol Group: Monoid {
    var inverse: Self { get }
}

public extension Group {
    public static func ** (a: Self, b: Int) -> Self {
        switch b {
        case let n where n > 0:
            return a * (a ** (n - 1))
        case let n where n < 0:
            return a.inverse * (a ** (n + 1))
        default:
            return Self.identity
        }
    }
    
    public static func formsSubgroup<S: Sequence>(_ elements: S) -> Bool where S.Element == Self {
        let list = Array(elements)
        let n = list.count
        
        // check ^-1 closed
        for g in list {
            if !elements.contains(g.inverse) {
                return false
            }
        }
        
        // check *-closed
        let combis = n.choose(2)
        for c in combis {
            let (g, h) = (list[c[0]], list[c[1]])
            if !elements.contains(g * h) {
                return false
            }
            if !elements.contains(h * g) {
                return false
            }
        }
        
        return true
    }
}

public extension Group where Self: FiniteSetType {
    public static func cyclicSubgroup(generator: Self) -> FiniteSubgroupStructure<Self> {
        var g = generator
        var set = Set([identity])
        while !set.contains(g) {
            set.insert(g)
            g = g * g
        }
        return FiniteSubgroupStructure(allElements: set)
    }
    
    public static var allCyclicSubgroups: [FiniteSubgroupStructure<Self>] {
        return allElements.map{ cyclicSubgroup(generator: $0) }.sorted{ $0.countElements < $1.countElements }
    }
    
    public static var allSubgroups: [FiniteSubgroupStructure<Self>] {
        let n = countElements
        if n == 1 {
            return [cyclicSubgroup(generator: identity)]
        }
        
        let cyclics = allCyclicSubgroups
        var unions: Set<Set<Self>> = Set()
        unions.insert(Set([identity]))
        
        for k in 2...cyclics.count {
            n.choose(k).forEach { c in
                let union: Set<Self> = c.map{ cyclics[$0] }.reduce([]){ $0.union($1.allElements) }
                
                // TODO improve algorithm
                if !unions.contains(union) && (n % union.count == 0) && formsSubgroup(union) {
                    unions.insert(union)
                }
            }
        }
        
        return unions
            .sorted{ $0.count < $1.count }
            .map{ FiniteSubgroupStructure(allElements: $0) }
    }
}

public protocol Subgroup: Submonoid where Super: Group {}

public extension Subgroup {
    public var inverse: Self {
        return Self(self.asSuper.inverse)
    }
}

// abstract protocol
public protocol _ProductGroup: Group, _ProductMonoid where Left: Group, Right: Group {}

public extension _ProductGroup {
    public var inverse: Self {
        return Self(_1.inverse, _2.inverse)
    }
}

// concrete struct
public struct ProductGroup<G1: Group, G2: Group>: _ProductGroup {
    public typealias Left = G1
    public typealias Right = G2
    
    public let _1: G1
    public let _2: G2
    
    public init(_ g1: G1, _ g2: G2) {
        self._1 = g1
        self._2 = g2
    }
}

// abstract protocol
public protocol _QuotientGroup: Group, QuotientSetType {
    associatedtype Sub: Subgroup
}

public extension _QuotientGroup where Base == Sub.Super {
    
    public static var identity: Self {
        return Self(Base.identity)
    }
    
    public var inverse: Self {
        return Self(representative.inverse)
    }
    
    public static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        return Sub.contains(a * b.inverse)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.representative * b.representative)
    }

    public static var symbol: String {
        return "\(Base.symbol)/\(Sub.symbol)"
    }
}

// concrete struct
public struct QuotientGroup<G, H>: _QuotientGroup where H: Subgroup, G == H.Super {
    public typealias Base = G
    public typealias Sub = H
    
    internal let g: G
    
    public init(_ g: G) {
        self.g = g
    }
    
    public var representative: G {
        return g
    }
    
    public var hashValue: Int {
        return Sub.contains(representative) ? 0 : 1 // might have efficiency issues.
    }
}
