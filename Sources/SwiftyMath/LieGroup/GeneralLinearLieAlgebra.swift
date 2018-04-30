//
//  GeneralLinearLieAlgebra.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/18.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct GeneralLinearLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing   = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        self.matrix = matrix
    }
    
    public static var dim: Int {
        let n = Size.intValue
        return n * n
    }
    
    public static var standardBasis: [GeneralLinearLieAlgebra<n, K>] {
        return SquareMatrix<n, K>.standardBasis.map{ GeneralLinearLieAlgebra($0) }
    }
    
    public var standardCoordinates: [CoeffRing] {
        return matrix.grid
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
    
    public static var dim: Int {
        let n = Size.intValue
        return n * n - 1
    }
    
    public static var standardBasis: [SpecialLinearLieAlgebra<n, K>] {
        typealias 𝔤 = SpecialLinearLieAlgebra<n, K>
        
        let E = SquareMatrix<n, K>.unit
        let n = Size.intValue
        
        return
            (0 ..< n).flatMap { i -> [𝔤] in
                (0 ..< n).compactMap { j -> 𝔤? in
                    (i != j) ? 𝔤(E(i, j)) : nil
                }
            }
            +
            (0 ..< n - 1).map { i -> 𝔤 in
                𝔤(E(i, i) - E(n - 1, n - 1))
            }
    }
    
    public var standardCoordinates: [CoeffRing] {
        let n = size
        return
            (0 ..< n).flatMap { i -> [CoeffRing] in
                (0 ..< n).compactMap { j -> CoeffRing? in
                    (i != j) ? matrix[i, j] : nil
                }
            }
            +
            (0 ..< n - 1).map { i in matrix[i, i] }
    }
    
    public static func contains(_ g: GeneralLinearLieAlgebra<n, K>) -> Bool {
        return g.matrix.trace == .zero
    }
    
    public static var symbol: String  {
        return "sl(\(n.intValue), \(K.symbol))"
    }
}
