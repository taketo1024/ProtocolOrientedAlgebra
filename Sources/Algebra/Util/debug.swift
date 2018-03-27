//
//  debug.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

private let precision = 1000.0

public class Debug {
    public static func measure<T>(_ f: () -> T) -> T {
        return measure("", f)
    }

    public static func measure<T>(_ label: String, _ f: () -> T) -> T {
        let date = Date()
        defer {
            let intv = -date.timeIntervalSinceNow
            if intv < 1 {
                print(label, ":\t\(round(intv * precision * 1000) / precision) msec.")
            } else {
                print(label, ":\t\(round(intv * precision) / precision) sec.")
            }
        }
        return f()
    }

    public static func log(_ msg: @autoclosure () -> String, _ b: Bool) {
        if b { print(msg()) }
    }
}

// TODO remove
public func log(_ msg: @autoclosure () -> String, _ b: Bool) {
    Debug.log(msg, b)
}
