//
//  Matrix.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

// MEMO:
// The implementation of a matrix-type can be changed by replacing the type parameter `Impl` of `MatrixIF`.
// The default implementation works over any ring, but is not useful for high-speed computation.

public typealias Matrix<R: Ring, n: SizeType, m: SizeType> = MatrixIF<DefaultMatrixImpl<R>, n, m>
public typealias Matrix1x1<R: Ring> = Matrix<R, _1, _1>
public typealias Matrix2x2<R: Ring> = Matrix<R, _2, _2>
public typealias Matrix3x3<R: Ring> = Matrix<R, _3, _3>
public typealias Matrix4x4<R: Ring> = Matrix<R, _4, _4>
public typealias MatrixDxD<R: Ring> = Matrix<R, DynamicSize, DynamicSize>

public typealias ColVector<R: Ring, n: SizeType> = Matrix<R, n, _1>
public typealias RowVector<R: Ring, m: SizeType> = Matrix<R, _1, m>

public typealias Vector1<R: Ring> = ColVector<R, _1>
public typealias Vector2<R: Ring> = ColVector<R, _2>
public typealias Vector3<R: Ring> = ColVector<R, _3>
public typealias Vector4<R: Ring> = ColVector<R, _4>
public typealias VectorD<R: Ring> = ColVector<R, DynamicSize>

public typealias MatrixSize = (rows: Int, cols: Int)
public typealias MatrixEntry<R: Ring> = (row: Int, col: Int, value: R)
public typealias RowEntry<R> = (col: Int, value: R)
public typealias ColEntry<R> = (row: Int, value: R)
