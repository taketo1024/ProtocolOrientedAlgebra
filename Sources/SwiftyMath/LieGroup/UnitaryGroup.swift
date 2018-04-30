//
//  UnitaryGroup.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct UnitaryGroup<n: _Int>: MatrixGroup {
    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, 𝐂>) -> Bool {
        return g.matrix.isUnitary
    }

    public static var symbol: String  {
        return "U(\(n.intValue))"
    }
}

public struct SpecialUnitaryGroup<n: _Int>: MatrixGroup {
    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, 𝐂>) -> Bool {
        return UnitaryGroup.contains(g) && SpecialLinearGroup.contains(g)
    }
}

