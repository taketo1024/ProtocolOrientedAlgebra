//
//  SymplecticGroup.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/Symplectic_group

// Note <n> is the size of the matrix, thus must be even.
public struct SymplecticGroup<n: _Int, K: Field>: MatrixGroup {
    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        assert(n.intValue.isEven)
        self.matrix = matrix
    }

    public static var standardSymplecticMatrix: SymplecticGroup<n, K> {
        assert(n.intValue.isEven)
        return SymplecticGroup( SquareMatrix<n, K>.standardSymplecticMatrix )
    }

    public static func contains(_ g: GeneralLinearGroup<n, K>) -> Bool {
        let J = standardSymplecticMatrix.asGL
        return g.transposed * J * g == J
    }

    public static var symbol: String  {
        return "Sp(\(n.intValue), \(K.symbol))"
    }
}


// Note <n> is the size of the matrix, thus must be even.
// see: https://en.wikipedia.org/wiki/Symplectic_group#Sp(n)

public struct UnitarySymplecticGroup<n: _Int>: MatrixGroup {
    public let matrix: SquareMatrix<n, 𝐂>
    public init(_ matrix: SquareMatrix<n, 𝐂>) {
        assert(n.intValue.isEven)
        self.matrix = matrix
    }

    public static var standardSymplecticMatrix: UnitarySymplecticGroup<n> {
        return UnitarySymplecticGroup(SymplecticGroup.standardSymplecticMatrix.matrix)
    }

    public static func contains(_ g: GeneralLinearGroup<n, 𝐂>) -> Bool {
        return SymplecticGroup.contains(g) && UnitaryGroup<n>.contains(g)
    }

    public static var symbol: String  {
        return "USp(\(n.intValue))"
    }
}
