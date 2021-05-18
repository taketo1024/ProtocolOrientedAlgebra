//
//  Matrix.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

// MEMO:
// The implementation of a matrix-type can be changed by replacing the type parameter `Impl` of `MatrixIF`.
// The default implementation works over any ring, but is not useful for high-speed computation.

public typealias Matrix<n: SizeType, m: SizeType, R: Ring> = MatrixIF<DefaultMatrixImpl<R>, n, m>
public typealias Matrix1x1<R: Ring> = Matrix<_1, _1, R>
public typealias Matrix2x2<R: Ring> = Matrix<_2, _2, R>
public typealias Matrix3x3<R: Ring> = Matrix<_3, _3, R>
public typealias Matrix4x4<R: Ring> = Matrix<_4, _4, R>
public typealias MatrixDxD<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public typealias ColVector<n: SizeType, R: Ring> = Matrix<n, _1, R>
public typealias RowVector<m: SizeType, R: Ring> = Matrix<_1, m, R>

public typealias Vector1<R: Ring> = ColVector<_1, R>
public typealias Vector2<R: Ring> = ColVector<_2, R>
public typealias Vector3<R: Ring> = ColVector<_3, R>
public typealias Vector4<R: Ring> = ColVector<_4, R>
public typealias VectorD<R: Ring> = ColVector<DynamicSize, R>

public typealias MatrixSize = (rows: Int, cols: Int)
public typealias MatrixEntry<R: Ring> = (row: Int, col: Int, value: R)
