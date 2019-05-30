//
//  SquareMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias SquareMatrix<n: _Int, R: Ring> = _Matrix<n, n, R>

public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

extension SquareMatrix: Monoid where n == m {}

extension SquareMatrix: Ring where n == m {
    public init(from n : 𝐙) {
        self.init(scalar: R(from: n))
    }
    
    public static var identity: _Matrix<n, n, R> {
        assert(!n.isDynamic)
        return _Matrix<n, n, R> { $0 == $1 ? .identity : .zero }
    }
    
    public var isInvertible: Bool {
        return determinant.isInvertible
    }
    
    public var inverse: _Matrix<n, n, R>? {
        fatalError("matrix-inverse not yet supported for a general ring.")
    }
    
    public var isSquare: Bool {
        return rows == cols
    }
    
    public var isZero: Bool {
        return self.allSatisfy{ (_, _, a) in a == .zero }
    }
    
    public var isDiagonal: Bool {
        return self.allSatisfy{ (i, j, a) in i == j || a == .zero }
    }
    
    public var isSymmetric: Bool {
        if !isSquare { return false }
        
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
        if !isSquare { return false }
        
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
        return isSquare && self.transposed * self == .identity
    }
    
    public func pow(_ n: 𝐙) -> SquareMatrix<n, R> {
        assert(isSquare)
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
    
    public var trace: R {
        assert(isSquare)
        return (0 ..< rows).sum { i in self[i, i] }
    }
    
    public var determinant: R {
        assert(isSquare)
        print("warn: computing determinant for a general ring.")
        return DPermutation.allPermutations(ofLength: rows).sum { s in
            let e = R(from: s.signature)
            let term = (0 ..< rows).multiply { i in self[i, s[i]] }
            print("\t", e, term)
            return e * term
        }
    }
}

public extension SquareMatrix where n == m, n == _1 {
    var asScalar: R {
        return self[0, 0]
    }
}

public extension SquareMatrix where n == m, R: EuclideanRing {
    var determinant: R {
        assert(isSquare)
        switch rows {
        case 0: return .identity
        case 1: return self[0, 0]
        case 2: return self[0, 0] * self[1, 1] - self[1, 0] * self[0, 1]
        default: return elimination().determinant
        }
    }
    
    var inverse: _Matrix<n, n, R>? {
        assert(isSquare)
        switch rows {
        case 0: return .identity
        case 1: return self[0, 0].inverse.flatMap{ _Matrix($0) }
        case 2:
            let det = determinant
            return (det.isInvertible)
                ? det.inverse! * _Matrix(self[1, 1], -self[0, 1], -self[1, 0], self[0, 0])
                : nil
        default: return elimination().inverse
        }
    }
}

public extension SquareMatrix where n == m, R == 𝐂 {
    var isHermitian: Bool {
        if !isSquare { return false }
        
        if rows <= 1 {
            return true
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == self[j, i].conjugate
            }
        }
    }
    
    var isSkewHermitian: Bool {
        if !isSquare { return false }
        
        if rows <= 1 {
            return isZero
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == -self[j, i].conjugate
            }
        }
    }
    
    var isUnitary: Bool {
        return isSquare && self.adjoint * self == .identity
    }
}

public extension SquareMatrix where n == m {
    static var standardSymplecticMatrix: SquareMatrix<n, R> {
        assert(!n.isDynamic)
        assert(n.intValue.isEven)
        
        let m = n.intValue / 2
        return SquareMatrix { (i, j) in
            if i < m, j >= m, i == (j - m) {
                return -.identity
            } else if i >= m, j < m, (i - m) == j {
                return .identity
            } else {
                return .zero
            }
        }
    }
}

// TODO merge with PowerSeries.exp .
// must handle Int overflow...
public func exp<n, K>(_ A: SquareMatrix<n, K>) -> SquareMatrix<n, K> where K: Field, K: NormedSpace {
    if A == .zero {
        return .identity
    }
    
    var X = SquareMatrix<n, K>.identity
    var n = 0
    var cn = K.identity
    var An = X
    let e = A.maxNorm.ulp
    
    while true {
        n  = n + 1
        An = An * A
        cn = cn / K(from: n)
        
        let Bn = cn * An
        if Bn.maxNorm <= e {
            break
        } else {
            X = X + Bn
        }
    }
    
    return X
}
