//
//  Letters.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct Expression {
    public static func sup(_ i: Int) -> String {
        return String( String(i).map { c in
            switch c {
            case "0": return "⁰"
            case "1": return "¹"
            case "2": return "²"
            case "3": return "³"
            case "4": return "⁴"
            case "5": return "⁵"
            case "6": return "⁶"
            case "7": return "⁷"
            case "8": return "⁸"
            case "9": return "⁹"
            default: return c
            }
        } )
    }

    public static func sub(_ i: Int) -> String {
        return String( String(i).map { c in
            switch c {
            case "0": return "₀"
            case "1": return "₁"
            case "2": return "₂"
            case "3": return "₃"
            case "4": return "₄"
            case "5": return "₅"
            case "6": return "₆"
            case "7": return "₇"
            case "8": return "₈"
            case "9": return "₉"
            default: return c
            }
        } )
    }

    public static func symbol(_ x: String, sub i: Int? = nil, sup j: Int? = nil) -> String {
        return "\(x)\(i.flatMap{ sub($0) } ?? "")\(j.flatMap{ sup($0) } ?? "")"
    }

    public static func term<R: Ring>(_ a: R, _ x: String, _ n: Int = 1) -> String {
        switch (a, n) {
        case ( 0, _): return "0"
        case ( _, 0): return "\(a)"
        case ( 1, 1): return "\(x)"
        case (-1, 1): return "-\(x)"
        case ( 1, _): return "\(x)\(sup(n))"
        case (-1, _): return "-\(x)\(sup(n))"
        default:      return "\(a)\(x)\(sup(n))"
        }
    }

    public static func terms<R: Ring>(_ op: String, _ terms: [(R, String, Int)]) -> String {
        return terms.map{ (a, x, n) in term(a, x, n) }.joined(separator: " \(op) ")
    }
}
