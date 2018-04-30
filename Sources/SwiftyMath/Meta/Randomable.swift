//
//  Random.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

private var randInit = false
public extension Double {
    public static func random() -> Double {
        if !randInit {
            srand48(time(nil))
            randInit = true
        }
        return drand48()
    }
}

public protocol Randomable {
    static func random(_ upperBound: Int) -> Self
    static func random(_ lowerBound: Int, _ upperBound: Int) -> Self
}

public extension Randomable {
    public static func random(_ upperBound: Int) -> Self {
        return random(0, upperBound)
    }
}

extension 𝐙: Randomable {
    public static func random(_ lowerBound: Int, _ upperBound: Int) -> 𝐙 {
        if lowerBound < upperBound {
            return 𝐙(Double.random() * Double(upperBound - lowerBound + 1)) + lowerBound
        } else {
            return 0
        }
    }
}

extension 𝐐: Randomable {
    public static func random(_ lowerBound: Int, _ upperBound: Int) -> 𝐐 {
        if lowerBound < upperBound {
            let q = 𝐙.random(1, 10)
            let p = 𝐙.random(q * lowerBound, q * upperBound)
            return 𝐐(p, q)
        } else {
            return 0
        }
    }
}

/*
// TODO conditional conformance - Matrix: Randomable
public extension _Matrix where R: Randomable {
    public static func random(_ lowerBound: Int, _ upperBound: Int) -> _Matrix<n, m, R> {
        return _Matrix { (_, _) in  R.random(lowerBound, upperBound) }
    }

    public static func random(rank r: Int, shuffle s: Int = 50) -> _Matrix<n, m, R> {
        let A = _Matrix<n, m, R>{ (i, j) in (i == j && i < r) ? .identity : .zero }
        let P = _Matrix<n, n, R>.randRegular(shuffle: s)
        let Q = _Matrix<m, m, R>.randRegular(shuffle: s)
        return P * A * Q
    }
}

public extension _Matrix where R: Randomable, n == m {
    public static func randRegular(_ size: Int? = nil, shuffle: Int = 50) -> _Matrix<n, n, R> {
        let s = size ?? n.intValue
        let A = MatrixImpl<R>.identity(s)

        for _ in 0 ..< shuffle {
            let i = Int.random(0, A.rows)
            let j = Int.random(0, A.cols)
            if i == j {
                continue
            }

            switch Int.random(6) {
            case 0: A.addRow(at: i, to: j, multipliedBy: R.random(1, 2))
            case 1: A.addCol(at: i, to: j, multipliedBy: R.random(1, 2))
            case 2: A.multiplyRow(at: i, by: -.identity)
            case 3: A.multiplyCol(at: i, by: -.identity)
            case 4: A.swapRows(i, j)
            case 5: A.swapCols(i, j)
            default: ()
            }
        }

        return _Matrix(A)
    }
}
*/
