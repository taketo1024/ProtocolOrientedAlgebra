//
//  SquareMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>

public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

extension Matrix: Monoid, Ring where n == m, n: StaticSizeType {
    public init(from n : 𝐙) {
        self.init(scalar: R(from: n))
    }
    
    public var size: Int {
        return rows
    }
    
    public static var identity: Matrix<n, n, R> {
        return Matrix<n, n, R> { $0 == $1 ? .identity : .zero }
    }
    
    public var isInvertible: Bool {
        return determinant.isInvertible
    }
    
    public var inverse: Matrix<n, n, R>? {
        if size >= 5 {
            print("warn: Directly computing matrix-inverse can be extremely slow. Use elimination().determinant instead.")
        }
        
        guard let dInv = determinant.inverse else {
            return nil
        }
        return dInv * SquareMatrix<n, R> { (i, j) in cofactor(j, i) }
    }
    
    public func cofactor(_ i: Int, _ j: Int) -> R {
        let ε = R(from: (-1).pow(i + j))
        let d = impl.submatrix({ $0 != i }, { $0 != j }).determinant
        return ε * d
    }
    
    public func pow(_ n: 𝐙) -> SquareMatrix<n, R> {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
    
    public var trace: R {
        return (0 ..< size).sum { i in self[i, i] }
    }
    
    public var determinant: R {
        if size >= 5 {
            print("warn: Directly computing determinant can be extremely slow. Use elimination().determinant instead.")
        }
        
        return impl.determinant
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        return self[0, 0]
    }
}
