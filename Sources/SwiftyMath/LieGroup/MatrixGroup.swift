//
//  MatrixGroup.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public protocol MatrixGroup: Group {
    associatedtype Size: _Int
    associatedtype CoeffRing: Field
    init(_ g: SquareMatrix<Size, CoeffRing>)

    var size: Int { get }
    var matrix: SquareMatrix<Size, CoeffRing> { get }
    var asGL: GeneralLinearGroup<Size, CoeffRing> { get }

    var transposed: Self { get }
    var determinant: CoeffRing { get }
    var trace: CoeffRing { get }

    static func contains(_ g: GeneralLinearGroup<Size, CoeffRing>) -> Bool
}

public extension MatrixGroup {
    public init(_ grid: CoeffRing ...) {
        self.init(SquareMatrix(grid))
    }

    public init(_ grid: [CoeffRing]) {
        self.init(SquareMatrix(grid))
    }

    public init(generator g: (Int, Int) -> CoeffRing) {
        self.init(SquareMatrix(generator: g))
    }

    public var size: Int {
        return matrix.rows
    }

    public static var identity: Self {
        return Self( .identity )
    }

    public var inverse: Self {
        return Self(matrix.inverse!)
    }

    public var determinant: CoeffRing {
        return matrix.determinant
    }

    public var trace: CoeffRing {
        return matrix.trace
    }

    public var transposed: Self {
        return Self( matrix.transposed )
    }

    public var asGL: GeneralLinearGroup<Size, CoeffRing> {
        return GeneralLinearGroup( matrix )
    }

    public static func *(a: Self, b: Self) -> Self {
        return Self( a.matrix * b.matrix )
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.matrix == rhs.matrix
    }

    public var hashValue: Int {
        return matrix.hashValue
    }

    public var description: String {
        return matrix.description
    }

    public var detailDescription: String {
        return matrix.detailDescription
    }
}

public extension MatrixGroup where CoeffRing == 𝐂 {
    public var adjoint: Self {
        return Self(matrix.adjoint)
    }

    // A + iB -> (A, -B; B, A)
    public func asReal<m: _Int>() -> GeneralLinearGroup<m, 𝐑> {
        let n = size
        assert(m.intValue == 2 * n)

        let (A, B) = (matrix.realPart, matrix.imaginaryPart)

        return GeneralLinearGroup<m, 𝐑> { (i, j) in
            if i < n, j < n {
                return A[i, j]
            } else if i < n, j >= n {
                return -B[i, j - n]
            } else if i >= n, j < n {
                return B[i - n, j]
            } else {
                return A[i - n, j - n]
            }
        }
    }
}
