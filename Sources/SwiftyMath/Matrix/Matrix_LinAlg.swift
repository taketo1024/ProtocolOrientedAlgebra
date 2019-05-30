//
//  Matrix_LinAlg.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/05/30.
//

import Foundation

extension Matrix: NormedSpace where R: NormedSpace {
    public var norm: 𝐑 {
        return √( sum { (_, _, a) in a.norm.pow(2) } )
    }
    
    public var maxNorm: 𝐑 {
        return self.map { $0.2.norm }.max() ?? 𝐑.zero
    }
}

public extension Matrix where R == 𝐑 {
    var asComplex: Matrix<n, m, 𝐂> {
        return Matrix<n, m, 𝐂>(impl.mapValues{ 𝐂($0) })
    }
}

public extension Matrix where R == 𝐂 {
    var realPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(impl.mapValues{ $0.realPart })
    }
    
    var imaginaryPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(impl.mapValues{ $0.imaginaryPart })
    }
    
    var adjoint: Matrix<m, n, R> {
        return Matrix<m, n, R>(impl.transposed.mapValues{ $0.conjugate })
    }
}

public extension SquareMatrix where n == m, n: StaticSizeType, R == 𝐂 {
    var isHermitian: Bool {
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
        return self.adjoint * self == .identity
    }
}

public extension SquareMatrix where n == m, n: StaticSizeType {
    static var standardSymplecticMatrix: SquareMatrix<n, R> {
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
