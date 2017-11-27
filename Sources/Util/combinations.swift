//
//  combinations.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension IntegerNumber {
    public var factorial: IntegerNumber {
        if self < 0 {
            fatalError("factorial of negative number.")
        }
        return (self == 0) ? 1 : self * (self - 1).factorial
    }

    public var permutations: [[IntegerNumber]] {
        let n = self
        switch n {
        case 0:
            return [[]]
        default:
            let prev = (n - 1).permutations
            return (0 ..< self).flatMap({ (i: Int) -> [[Int]] in
                prev.map({ (s: [Int]) -> [Int] in
                    [i] + s.map{ $0 < i ? $0 : $0 + 1 }
                })
            })
        }
    }

    public func choose(_ k: Int) -> [[Int]] {
        let n = self
        switch (n, k) {
        case _ where n < k:
            return []
        case (_, 0):
            return [[]]
        default:
            return (n - 1).choose(k) + (n - 1).choose(k - 1).map{ $0 + [n - 1] }
        }
    }

    public func multichoose(_ k: Int) -> [[Int]] {
        let n = self
        switch (n, k) {
        case _ where n < 0:
            return []
        case (_, 0):
            return [[]]
        default:
            return (0 ... k).flatMap { (i: Int) -> [[Int]] in
                (n - 1).multichoose(k - i).map{ (c: [Int]) -> [Int] in c + Array(repeating: n - 1, count: i) }
            }
        }
    }
}

