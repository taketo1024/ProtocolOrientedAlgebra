//
//  SquareMatrix.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias SquareMatrix<n: _Int, R: Ring> = Matrix<n, n, R>

// TODO: conform to Ring after conditional conformance is supported.
public extension SquareMatrix where n == m {
    public static var identity: Matrix<n, n, R> {
        return Matrix<n, n, R> { $0 == $1 ? 1 : 0 }
    }

    public var size: Int {
        return rows
    }

    public var trace: R {
        return (0 ..< rows).sum { i in self[i, i] }
    }

    public var isZero: Bool {
        return self.forAll{ (_, _, r) in r == .zero }
    }

    public var isDiagonal: Bool {
        return self.forAll{ (i, j, r) in (i == j) || r == .zero }
    }

    public var isSymmetric: Bool {
        if size <= 1 {
            return true
        }
        return (0 ..< rows - 1).forAll { i in
            (i + 1 ..< cols).forAll { j in
                self[i, j] == self[j, i]
            }
        }
    }

    public var isSkewSymmetric: Bool {
        if size <= 1 {
            return isZero
        }
        return (0 ..< rows - 1).forAll { i in
            (i + 1 ..< cols).forAll { j in
                self[i, j] == -self[j, i]
            }
        }
    }

    public var isOrthogonal: Bool {
        return self.transposed * self == .identity
    }

    public static func ** (a: Matrix<n, n, R>, k: Int) -> Matrix<n, n, R> {
        return k == 0 ? .identity : a * (a ** (k - 1))
    }
}

public extension SquareMatrix where n == m, R: EuclideanRing {
    public var determinant: R {
        switch size {
        case 0: return .identity
        case 1: return self[0, 0]
        case 2: return self[0, 0] * self[1, 1] - self[1, 0] * self[0, 1]
        default: return eliminate().determinant
        }
    }

    public var isInvertible: Bool {
        return determinant.isInvertible
    }

    public var inverse: Matrix<n, n, R>? {
        switch size {
        case 0: return .identity
        case 1: return self[0, 0].inverse.flatMap{ Matrix($0) }
        case 2:
            let det = determinant
            return (det.isInvertible)
                ? det.inverse! * Matrix(self[1, 1], -self[0, 1], -self[1, 0], self[0, 0])
                : nil
        default: return eliminate().inverse
        }
    }
}

public extension SquareMatrix where n == m, R == 𝐂 {
    public var isHermitian: Bool {
        if size <= 1 {
            return true
        }
        return (0 ..< rows - 1).forAll { i in
            (i + 1 ..< cols).forAll { j in
                self[i, j] == self[j, i].conjugate
            }
        }
    }

    public var isSkewHermitian: Bool {
        if size <= 1 {
            return isZero
        }
        return (0 ..< rows - 1).forAll { i in
            (i + 1 ..< cols).forAll { j in
                self[i, j] == -self[j, i].conjugate
            }
        }
    }

    public var isUnitary: Bool {
        return self.adjoint * self == .identity
    }
}

public extension SquareMatrix where n == m {
    public static var standardSymplecticMatrix: SquareMatrix<n, R> {
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
    let e = A.maxNorm.error

    while true {
        n  = n + 1
        An = An * A
        cn = cn / K(from: n)

        let Bn = cn * An
        if Bn.maxNorm.value < e {
            break
        } else {
            X = X + Bn
        }
    }

    return X
}
