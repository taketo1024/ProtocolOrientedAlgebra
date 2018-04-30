//
//  OrthogonalLieAlgebra.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct OrthogonalLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing   = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }

    public static var dim: Int {
        let n = Size.intValue
        return n * (n - 1) / 2
    }
    
    public static var standardBasis: [OrthogonalLieAlgebra<n, K>] {
        typealias 𝔤 = OrthogonalLieAlgebra<n, K>
        
        let n = Size.intValue
        let E = SquareMatrix<n, K>.unit
        
        return (0 ..< n - 1).flatMap{ i -> [𝔤] in
            (i + 1 ..< n).map { j -> 𝔤 in
                𝔤(E(i, j) - E(j, i))
            }
        }
    }
    
    public var standardCoordinates: [K] {
        let n = size
        return (0 ..< n - 1).flatMap{ i -> [K] in
            (i + 1 ..< n).map { j -> K in matrix[i, j] }
        }
    }
    
    public static func contains(_ X: GeneralLinearLieAlgebra<n, K>) -> Bool {
        return X.matrix.isSkewSymmetric
    }
    
    public static var symbol: String  {
        return "o(\(n.intValue))"
    }
}
