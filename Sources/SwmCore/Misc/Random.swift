//
//  Random.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol Randomable {
    static func random() -> Self
}

extension Randomable where Self: AdditiveGroup {
    public static func randomNonZero() -> Self {
        while true {
            let r = random()
            if !r.isZero {
                return r
            }
        }
    }
}

public protocol RangeRandomable: Randomable {
    associatedtype RangeBound: Comparable
    static func random(in range: Range<RangeBound>) -> Self
    static func random(in range: ClosedRange<RangeBound>) -> Self
}
