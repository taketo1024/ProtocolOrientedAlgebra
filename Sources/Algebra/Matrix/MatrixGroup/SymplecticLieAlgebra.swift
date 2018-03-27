//
//  SymplecticLieAlgebra.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/Symplectic_group

import Foundation

// Note <n> is the size of the matrix, thus must be even.
public struct SymplecticLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        assert(n.intValue.isEven)
        self.matrix = matrix
    }

    public static func contains(_ X: GeneralLinearLieAlgebra<n, K>) -> Bool {
        if !n.intValue.isEven {
            return false
        }

        let J = SquareMatrix<n, K>.standardSymplecticMatrix
        let A = X.matrix.transposed * J
        let B = -J * X.matrix
        return A == B

        // return X.matrix.transposed * J == (-J) * X.matrix // expression was too complex? wtf...
    }

    public static var symbol: String  {
        return "sp(\(n.intValue), \(K.symbol))"
    }
}


// Note <n> is the size of the matrix, thus must be even.
// see: https://en.wikipedia.org/wiki/Symplectic_group#Sp(n)

public struct UnitarySymplecticLieAlgebra<n: _Int>: MatrixLieAlgebra {
    public typealias CoeffRing = 𝐑
    public typealias ElementRing = 𝐂

    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        assert(n.intValue.isEven)
        self.matrix = matrix
    }

    public static func contains(_ X: GeneralLinearLieAlgebra<n, 𝐂>) -> Bool {
        return SymplecticLieAlgebra<n, 𝐂>.contains(X) && UnitaryLieAlgebra<n>.contains(X)
    }

    public static var symbol: String  {
        return "usp(\(n.intValue))"
    }
}

