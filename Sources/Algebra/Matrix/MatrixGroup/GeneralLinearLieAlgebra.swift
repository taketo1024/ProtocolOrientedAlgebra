//
//  GeneralLinearLieAlgebra.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/18.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct GeneralLinearLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing   = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearLieAlgebra<n, K>) -> Bool {
        return true
    }

    public static var symbol: String  {
        return "gl(\(n.intValue), \(K.symbol))"
    }
}

public struct SpecialLinearLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing   = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearLieAlgebra<n, K>) -> Bool {
        return g.matrix.trace == .zero
    }

    public static var symbol: String  {
        return "sl(\(n.intValue), \(K.symbol))"
    }
}
