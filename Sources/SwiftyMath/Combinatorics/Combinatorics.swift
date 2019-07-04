//
//  combinations.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension 𝐙 {
    func choose(_ k: Int) -> [[Int]] {
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
    
    func multichoose(_ k: Int) -> [[Int]] {
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
    
    var partitions: [[Int]] {
        assert(self >= 0)
        if self == 0 {
            return [[]]
        } else {
            return self.partitions(lowerBound: 1)
        }
    }
    
    internal func partitions(lowerBound: Int) -> [[Int]] {
        let n = self
        if lowerBound > n {
            return []
        } else {
            return (lowerBound ... n).flatMap { i -> [[Int]] in
                let ps = (n - i).partitions(lowerBound: Swift.max(i, lowerBound))
                return ps.map { I in [i] + I }
            } + [[n]]
        }
    }
}

