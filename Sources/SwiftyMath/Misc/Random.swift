//
//  Random.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol Randomable: Comparable {
    static func random(in range: Range<Self>) -> Self
    static func random(in range: ClosedRange<Self>) -> Self
}
