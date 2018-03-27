//
//  UnitaryLieAlgebra.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct UnitaryLieAlgebra<n: _Int>: MatrixLieAlgebra {
    public typealias CoeffRing   = 𝐑 // MEMO: not a C-vec sp.
    public typealias ElementRing = 𝐂

    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        self.matrix = matrix
    }

    public static func contains(_ X: GeneralLinearLieAlgebra<n, 𝐂>) -> Bool {
        return X.matrix.isSkewHermitian
    }

    public static var symbol: String  {
        return "u(\(n.intValue))"
    }
}

public struct SpecialUnitaryLieAlgebra<n: _Int>: MatrixLieAlgebra {
    public typealias CoeffRing   = 𝐑 // MEMO: not a C-vec sp.
    public typealias ElementRing = 𝐂

    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearLieAlgebra<n, 𝐂>) -> Bool {
        return UnitaryLieAlgebra.contains(g) && SpecialLinearLieAlgebra.contains(g)
    }
}
