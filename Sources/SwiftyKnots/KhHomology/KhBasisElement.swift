//
//  KhBasisElement.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/19.
//

import SwiftyMath

public enum KhBasisElement: String, BasisElementType, Comparable, Codable {
    case I
    case X
    
    public typealias Product = (KhBasisElement, KhBasisElement) -> [KhBasisElement]
    public typealias Coproduct = (KhBasisElement) -> [(KhBasisElement, KhBasisElement)]
    
    public var degree: Int {
        switch self {
        case .I: return +1
        case .X: return -1
        }
    }
    
    public static func <(e1: KhBasisElement, e2: KhBasisElement) -> Bool {
        return e1.degree < e2.degree
    }
    
    public static func μ(_ e1: KhBasisElement, _ e2: KhBasisElement) -> [KhBasisElement] {
        switch (e1, e2) {
        case (.I, .I): return [.I]
        case (.I, .X), (.X, .I): return [.X]
        case (.X, .X): return []
        }
    }
    
    public static func Δ(_ e: KhBasisElement) -> [(KhBasisElement, KhBasisElement)] {
        switch e {
        case .I: return [(.I, .X), (.X, .I)]
        case .X: return [(.X, .X)]
        }
    }

    public static func μL(_ e1: KhBasisElement, _ e2: KhBasisElement) -> [KhBasisElement] {
        switch (e1, e2) {
        case (.I, .I), (.I, .X), (.X, .I): return []
        case (.X, .X): return [.I]
        }
    }
    
    public static func ΔL(_ e: KhBasisElement) -> [(KhBasisElement, KhBasisElement)] {
        switch e {
        case .I: return []
        case .X: return [(.I, .I)]
        }
    }
    
    public var description: String {
        return (self == .I) ? "I" : "X"
    }
}
