//
//  LieAlgebra.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public protocol MatrixLieAlgebra: FiniteDimLieAlgebra {
    associatedtype Size: _Int

    // MEMO: Usually ElementRing == CoeffRing,
    //       but for example u(n) has C-matrices, but only an R-vec. sp.
    associatedtype ElementRing: Field

    init(_ g: SquareMatrix<Size, ElementRing>)
    var size: Int { get }
    var matrix: SquareMatrix<Size, ElementRing> { get }

    static func contains(_ g: GeneralLinearLieAlgebra<Size, ElementRing>) -> Bool
}

public extension MatrixLieAlgebra {
    public init(_ grid: ElementRing ...) {
        self.init(SquareMatrix(grid))
    }

    public init(_ grid: [ElementRing]) {
        self.init(SquareMatrix(grid))
    }

    public init(generator g: (Int, Int) -> ElementRing) {
        self.init(SquareMatrix(generator: g))
    }

    public var size: Int {
        return Size.intValue
    }

    public var trace: ElementRing {
        return matrix.trace
    }

    public static var zero: Self {
        return Self( .zero )
    }

    public static func +(a: Self, b: Self) -> Self {
        return Self(a.matrix + b.matrix)
    }

    public static prefix func -(a: Self) -> Self {
        return Self(-a.matrix)
    }

    public func bracket(_ b: Self) -> Self {
        let (X, Y) = (self.matrix, b.matrix)
        return Self(X * Y - Y * X)
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

public extension MatrixLieAlgebra where CoeffRing == ElementRing {
    public static func *(a: Self, b: CoeffRing) -> Self {
        return Self( a.matrix * b )
    }

    public static func *(a: CoeffRing, b: Self) -> Self {
        return Self( a * b.matrix )
    }
}

public extension MatrixLieAlgebra where CoeffRing: Subfield, CoeffRing.Super == ElementRing {
    public static func *(a: Self, b: CoeffRing) -> Self {
        return Self( a.matrix * b.asSuper )
    }

    public static func *(a: CoeffRing, b: Self) -> Self {
        return Self( a.asSuper * b.matrix )
    }
}

public func exp<𝔤: MatrixLieAlgebra>(_ X: 𝔤) -> GeneralLinearGroup<𝔤.Size, 𝔤.ElementRing> where 𝔤.ElementRing : NormedSpace {
    return GeneralLinearGroup( exp(X.matrix) )
}
