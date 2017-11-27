//
//  Random.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/10/18.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol Randomable {
    static func rand(_ upperBound: Int) -> Self
    static func rand(_ lowerBound: Int, _ upperBound: Int) -> Self
}

public extension Randomable {
    public static func rand(_ upperBound: Int) -> Self {
        return rand(0, upperBound)
    }
}

extension IntegerNumber: Randomable {
    public static func rand(_ lowerBound: Int, _ upperBound: Int) -> IntegerNumber {
        if lowerBound < upperBound {
            return IntegerNumber(arc4random()) % (upperBound - lowerBound) + lowerBound
        } else {
            return 0
        }
    }
}

extension RationalNumber: Randomable {
    public static func rand(_ lowerBound: Int, _ upperBound: Int) -> RationalNumber {
        if lowerBound < upperBound {
            let q = IntegerNumber.rand(1, 10)
            let p = IntegerNumber.rand(q * lowerBound, q * upperBound)
            return RationalNumber(p, q)
        } else {
            return 0
        }
    }
}

// TODO conditional conformance - Matrix: Randomable
public extension Matrix where R: Randomable {
    public static func rand(_ lowerBound: Int, _ upperBound: Int) -> Matrix<n, m, R> {
        return Matrix { (_, _) in  R.rand(lowerBound, upperBound) }
    }
    
    public static func rand(rank r: Int, shuffle s: Int = 50) -> Matrix<n, m, R> {
        let A = Matrix<n, m, R>{ (i, j) in (i == j && i < r) ? .identity : .zero }
        let P = Matrix<n, n, R>.randRegular(shuffle: s)
        let Q = Matrix<m, m, R>.randRegular(shuffle: s)
        return P * A * Q
    }
}

public extension Matrix where R: Randomable, n == m {
    public static func randRegular(_ size: Int? = nil, shuffle: Int = 50) -> Matrix<n, n, R> {
        let s = size ?? n.intValue
        let A = ComputationalMatrix<R>.identity(s)
        
        for _ in 0 ..< shuffle {
            let i = Int.rand(0, A.rows)
            let j = Int.rand(0, A.cols)
            if i == j {
                continue
            }
            
            switch Int.rand(6) {
            case 0: A.addRow(at: i, to: j, multipliedBy: R.rand(1, 2))
            case 1: A.addCol(at: i, to: j, multipliedBy: R.rand(1, 2))
            case 2: A.multiplyRow(at: i, by: -1)
            case 3: A.multiplyCol(at: i, by: -1)
            case 4: A.swapRows(i, j)
            case 5: A.swapCols(i, j)
            default: ()
            }
        }
        
        return A.asMatrix()
    }
}
