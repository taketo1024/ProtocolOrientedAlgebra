//
//  GL.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct GeneralLinearGroup<n: _Int, K: Field>: MatrixGroup {
    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, K>) -> Bool {
        return true
    }

    public static func *(a: K, b: GeneralLinearGroup<n, K>) -> GeneralLinearGroup<n, K> {
        assert(a.isInvertible)
        return GeneralLinearGroup( a * b.matrix )
    }

    public static func *(a: GeneralLinearGroup<n, K>, b: K) -> GeneralLinearGroup<n, K> {
        assert(b.isInvertible)
        return GeneralLinearGroup( a.matrix * b )
    }

    public static var symbol: String  {
        return "GL(\(n.intValue), \(K.symbol))"
    }
}

public struct SpecialLinearGroup<n: _Int, K: Field>: MatrixGroup {
    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }

    public static func contains(_ g: GeneralLinearGroup<n, K>) -> Bool {
        return g.determinant == .identity
    }

    public static var symbol: String  {
        return "SL(\(n.intValue), \(K.symbol))"
    }
}
