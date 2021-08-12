//
//  FractionField.swift
//  
//
//  Created by Taketo Sano on 2021/08/12.
//

public protocol FractionField: Field {
    associatedtype Base: EuclideanRing
    
    var numerator: Base { get }
    var denominator: Base { get }
    
    init(_ n: Base)
    init(_ p: Base, _ q: Base)
    init(reduced p: Base, _ q: Base) // override point
}

extension FractionField {
    @inlinable
    public init(from n: Int) {
        self.init(Base(from: n))
    }
    
    @inlinable
    public init(_ n: Base) {
        self.init(n, .identity)
    }
    
    @inlinable
    public init(_ p: Base, _ q: Base) {
        precondition(!q.isZero, "Given 0 for the dominator.")
        
        let a = q.normalizingUnit
        if a.isIdentity {
            self.init(normalized: p, q)
        } else {
            self.init(normalized: p * a, q * a)
        }
    }

    @inlinable
    internal init(normalized p: Base, _ q: Base) {
        switch (p, q) {
        case (_, .identity):
            self.init(reduced: p, .identity)
        case (.zero, _):
            self.init(reduced: .zero, .identity)
        default:
            let d = gcd(p, q).normalized
            switch d {
            case .identity:
                self.init(reduced: p, q)
            default:
                self.init(reduced: p / d, q / d)
            }
        }
    }
    
    @inlinable
    public var isZero: Bool {
        numerator.isZero
    }
    
    @inlinable
    public var isIdentity: Bool {
        numerator.isIdentity && denominator.isIdentity
    }
    
    @inlinable
    public var inverse: Self? {
        numerator.isZero ? nil : .init(denominator, numerator)
    }
    
    @inlinable
    public static func + (a: Self, b: Self) -> Self {
        let p = a.numerator * b.denominator + a.denominator * b.numerator
        let q = a.denominator * b.denominator
        return .init(p, q)
    }
    
    @inlinable
    public static prefix func - (a: Self) -> Self {
        .init(-a.numerator, a.denominator)
    }
    
    @inlinable
    public static func * (a: Self, b: Self) -> Self {
        .init(a.numerator * b.numerator, a.denominator * b.denominator)
    }
    
    public var description: String {
        switch denominator {
        case .identity:  return "\(numerator)"
        default: return "\(numerator)/\(denominator)"
        }
    }
}

extension FractionField where Base: Comparable {
    @inlinable
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
}

extension FractionField where Base: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(Base(integerLiteral: value))
    }
}
