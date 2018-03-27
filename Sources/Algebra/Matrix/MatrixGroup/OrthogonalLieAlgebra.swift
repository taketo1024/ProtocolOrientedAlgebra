//
//  OrthogonalLieAlgebra.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct OrthogonalLieAlgebra<n: _Int>: MatrixLieAlgebra {
    public typealias CoeffRing   = 𝐑
    public typealias ElementRing = 𝐑

    public let matrix: SquareMatrix<n, 𝐑>
    public init(_ matrix: SquareMatrix<n, 𝐑>) {
        self.matrix = matrix
    }

    public static func contains(_ X: GeneralLinearLieAlgebra<n, 𝐑>) -> Bool {
        return X.matrix.isSkewSymmetric
    }

    public static var symbol: String  {
        return "o(\(n.intValue))"
    }
}


