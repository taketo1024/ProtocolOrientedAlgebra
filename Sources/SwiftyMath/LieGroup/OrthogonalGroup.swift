//
//  OrthogonalGroup.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct OrthogonalGroup<n: _Int>: MatrixGroup {
    public let matrix: SquareMatrix<n, 𝐑>
    public init(_ matrix: SquareMatrix<n, 𝐑>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, 𝐑>) -> Bool {
        return g.matrix.isOrthogonal
    }
    
    public static var symbol: String  {
        return "O(\(n.intValue))"
    }
}

public struct SpecialOrthogonalGroup<n: _Int>: MatrixGroup {
    public let matrix: SquareMatrix<n, 𝐑>
    public init(_ matrix: SquareMatrix<n, 𝐑>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, 𝐑>) -> Bool {
        return OrthogonalGroup.contains(g) && SpecialLinearGroup.contains(g)
    }
    
    public static var symbol: String  {
        return "SO(\(n.intValue))"
    }
}

