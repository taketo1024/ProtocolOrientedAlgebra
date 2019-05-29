//
//  Indeterminate.swift
//  Sample
//
//  Created by Taketo Sano on 2018/05/11.
//

import Foundation

public protocol Indeterminate {
    static var symbol: String { get }
    static var degree: Int { get }
}

public extension Indeterminate {
    static var degree: Int {
        return 1
    }
}

public struct Indeterminate_x: Indeterminate {
    public static var symbol: String { return "x" }
}
