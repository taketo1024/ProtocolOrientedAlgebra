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
    
    public static var identity: Matrix<n, n, R> {
        return Matrix<n, n, R> { $0 == $1 ? .identity : .zero }
    }
    
    public var isInvertible: Bool {
        return determinant.isInvertible
    }
    
    public var inverse: Matrix<n, n, R>? {
        fatalError("matrix-inverse not yet supported for a general ring.")
    }
    
    public var isDiagonal: Bool {
        return self.nonZeroComponents.allSatisfy{ c in c.col == c.row }
    }
    
    public var isSymmetric: Bool {
        if rows <= 1 {
            return true
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == self[j, i]
            }
        }
    }
    
    public var isSkewSymmetric: Bool {
        if rows <= 1 {
            return isZero
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == -self[j, i]
            }
        }
    }
    
    public var isOrthogonal: Bool {
        return self.transposed * self == .identity
    }
    
    public func pow(_ n: 𝐙) -> SquareMatrix<n, R> {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
    
    public var trace: R {
        return (0 ..< rows).sum { i in self[i, i] }
    }
    
    public var determinant: R {
        print("warn: computing determinant for a general ring.")
        return DPermutation.allPermutations(ofLength: rows).sum { s in
            let e = R(from: s.signature)
            let term = (0 ..< rows).multiply { i in self[i, s[i]] }
            print("\t", e, term)
            return e * term
        }
    }
}

public extension Matrix where n == m, n == _1 {
    var asScalar: R {
        return self[0, 0]
    }
}

public extension Matrix where n == m, n: StaticSizeType, R: EuclideanRing {
    var determinant: R {
        switch rows {
        case 0: return .identity
        case 1: return self[0, 0]
        case 2: return self[0, 0] * self[1, 1] - self[1, 0] * self[0, 1]
        default: return elimination().determinant
        }
    }
    
    var inverse: Matrix<n, n, R>? {
        switch rows {
        case 0: return .identity
        case 1: return self[0, 0].inverse.flatMap{ Matrix($0) }
        case 2:
            let det = determinant
            return (det.isInvertible)
                ? det.inverse! * Matrix(self[1, 1], -self[0, 1], -self[1, 0], self[0, 0])
                : nil
        default: return elimination().inverse
        }
    }
}
