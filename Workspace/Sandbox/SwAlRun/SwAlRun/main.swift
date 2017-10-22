//
//  main.swift
//  SwAlRun
//
//  Created by omochimetaru on 2017/10/22.
//  Copyright © 2017年 omochimetaru. All rights reserved.
//

import Foundation
import SwiftyAlgebra


struct _2 : _Int {
    static let intValue: Int = 2
}
struct _100: _Int {
    static let intValue: Int = 100
}

func timeRun(_ f: () -> Void) {
    let start = Date()
    f()
    let end = Date()
    print(end.timeIntervalSince(start))
}

func main() {
    let a = Matrix<RealNumber, _100, _100>{ (i, j) in i == j ? 1 : 0 }
    let b = Matrix<RealNumber, _100, _100>{ (i, j) in i == j ? 1 : 0 }
    
    let n = 100
    
    timeRun {
        var x = 0
        for _ in 0..<n {
            let c = Matrix<RealNumber, _100, _100>.multiply1(a: a, b: b)
            x += c.rows
        }
        print(x)
    }

    timeRun {
        var x = 0
        for _ in 0..<n {
            let c = Matrix<RealNumber, _100, _100>.multiply2(a: a, b: b)
            x += c.rows
        }
        print(x)
    }

    timeRun {
        var x = 0
        for _ in 0..<n {
            let c = Matrix<RealNumber, _100, _100>.multiply3(a: a, b: b)
            x += c.rows
        }
        print(x)
    }

    timeRun {
        var x = 0
        for _ in 0..<n {
            let c = Matrix<RealNumber, _100, _100>.multiply4(a: a, b: b)
            x += c.rows
        }
        print(x)
    }
    
}

main()

