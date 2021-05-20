//
//  PolynomialType.swift
//  
//
//  Created by Taketo Sano on 2021/05/20.
//

public protocol PolynomialType: Ring {
    associatedtype BaseRing: Ring
    associatedtype Indeterminate
    associatedtype Exponent: AdditiveGroup & Hashable & Comparable // Int or MultiIndex<n>

    init(coeffs: [Exponent : BaseRing])
    var coeffs: [Exponent : BaseRing] { get }
    var leadExponent: Exponent { get }
}

extension PolynomialType {
    public init(from a: 𝐙) {
        self.init(BaseRing(from: a))
    }
    
    public init(_ a: BaseRing) {
        self.init(coeffs: [.zero: a])
    }
    
    public func coeff(_ exponent: Exponent) -> BaseRing {
        coeffs[exponent] ?? .zero
    }
    
    public func term(_ d: Exponent) -> Self {
        return Self(coeffs: [d: coeff(d)])
    }
    
    public static var zero: Self {
        .init(coeffs: [:])
    }
    
    public static var identity: Self {
        .init(coeffs: [.zero : .identity])
    }
    
    public var isZero: Bool {
        coeffs.count == 0
    }
    
    public var isIdentity: Bool {
        isMonomial && constCoeff == .identity
    }
    
    public var normalizingUnit: Self {
        .init(leadCoeff.normalizingUnit)
    }
    
    public var leadCoeff: BaseRing {
        coeff(leadExponent)
    }
    
    public var leadTerm: Self {
        term(leadExponent)
    }
    
    public var constCoeff: BaseRing {
        coeff(.zero)
    }
    
    public var constTerm: Self {
        term(.zero)
    }
    
    public var isConst: Bool {
        self == .zero || (isMonomial && !constTerm.isZero)
    }
    
    public var isMonic: Bool {
        leadCoeff.isIdentity
    }
    
    public var isMonomial: Bool {
        coeffs.count <= 1
    }
    
    public static func + (a: Self, b: Self) -> Self {
        .init(coeffs: a.coeffs.merging(b.coeffs, uniquingKeysWith: +))
    }
    
    public static prefix func - (a: Self) -> Self {
        .init(coeffs: a.coeffs.mapValues{ -$0 })
    }
    
    public static func * (r: BaseRing, a: Self) -> Self {
        .init(coeffs: a.coeffs.mapValues{ r * $0 } )
    }
    
    public static func * (a: Self, r: BaseRing) -> Self {
        .init(coeffs: a.coeffs.mapValues{ $0 * r } )
    }
    
    public static func * (a: Self, b: Self) -> Self {
        var coeffs: [Exponent: BaseRing] = [:]
        (a.coeffs * b.coeffs).forEach { (ca, cb) in
            let (x, r) = ca
            let (y, s) = cb
            coeffs[x + y] = coeffs[x + y, default: .zero] + r * s
        }
        return .init(coeffs: coeffs)
    }
}

