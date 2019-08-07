//
//  debug.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/19.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public class Debug {
    private static let precision = 1000.0
    
    public static func measure<T>(_ label: String? = nil, _ f: () -> T) -> T {
        if let label = label {
            print("Start: \(label)")
        }
        
        let date = Date()
        
        defer {
            let intv = -date.timeIntervalSinceNow
            let time: String
            if intv < 1 {
                time = "\(round(intv * precision * 1000) / precision) msec."
            } else {
                time = "\(round(intv * precision) / precision) sec."
            }
            if let label = label {
                print("End: \(label), \(time)")
            } else {
                print(time)
            }
        }
        
        return f()
    }
}
