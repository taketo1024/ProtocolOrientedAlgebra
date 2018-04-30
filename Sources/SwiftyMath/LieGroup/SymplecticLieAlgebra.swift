//
//  SymplecticLieAlgebra.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/Symplectic_group

// Note <n> is the size of the matrix, thus must be even.
public struct SymplecticLieAlgebra<n: _Int, K: Field>: MatrixLieAlgebra {
    public typealias CoeffRing = K
    public typealias ElementRing = K

    public let matrix: SquareMatrix<n, K>
    public init(_ matrix: SquareMatrix<n, K>) {
        assert(n.intValue.isEven)
        self.matrix = matrix
    }
    
    public static var dim: Int {
        let m = Size.intValue / 2
        return m * (2 * m + 1)
    }
    
    // sp<2n, K> = { [A, B; C, -A^t] | B, C ∈ Sym(n, K) }
    public static var standardBasis: [SymplecticLieAlgebra<n, K>] {
        typealias 𝔤 = SymplecticLieAlgebra<n, K>
        
        let m = Size.intValue / 2
        let E = SquareMatrix<n, K>.unit
        
        let A = (0 ..< m).flatMap { i -> [𝔤] in
                (0 ..< m).map { j -> 𝔤 in
                    𝔤(E(i, j) - E(m + j, m + i))
                }
            }
        
        let B = (0 ..< m - 1).flatMap { i -> [𝔤] in
                (1 ..< m).map { j -> 𝔤 in
                    𝔤(E(i, m + j) + E(j, m + i))
                }
            }
            +
            (0 ..< m).map { i -> 𝔤 in
                𝔤(E(i, m + i))
            }
    
        let C = (0 ..< m - 1).flatMap { i -> [𝔤] in
                (1 ..< m).map { j -> 𝔤 in
                    𝔤(E(m + i, j) + E(m + j, i))
                }
            }
            +
            (0 ..< m).map { i -> 𝔤 in
                𝔤(E(m + i, i))
            }
        
        return A + B + C
    }
    
    public var standardCoordinates: [K] {
        let m = size / 2
        let A = (0 ..< m).flatMap { i -> [K] in
                (0 ..< m).map { j -> K in matrix[i, j] }
            }
        
        let B = (0 ..< m - 1).flatMap { i -> [K] in
                (1 ..< m).map { j -> K in matrix[i, m + j] }
            }
            +
            (0 ..< m).map { i -> K in matrix[i, m + i] }
    
        let C = (0 ..< m - 1).flatMap { i -> [K] in
                (1 ..< m).map { j -> K in matrix[m + i, j] }
            }
            +
            (0 ..< m).map { i -> K in matrix[m + i, i] }
        
        return A + B + C
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
    
    public static var dim: Int {
        let m = Size.intValue / 2
        return m * (2 * m + 1)
    }
    
    // usp<2n> = sp<2n, C> ∩ u<2n>
    //         = { [A, B; -B^*, -A^t] | A ∈ u(n), C ∈ Sym(n, C) }
    public static var standardBasis: [UnitarySymplecticLieAlgebra<n>] {
        typealias 𝔤 = UnitarySymplecticLieAlgebra<n>
        fatalError("TODO")
    }
    
    public var standardCoordinates: [RealNumber] {
        fatalError()
    }
    
    public static func contains(_ X: GeneralLinearLieAlgebra<n, 𝐂>) -> Bool {
        return SymplecticLieAlgebra<n, 𝐂>.contains(X) && UnitaryLieAlgebra<n>.contains(X)
    }
    
    public static var symbol: String  {
        return "usp(\(n.intValue))"
    }
}

