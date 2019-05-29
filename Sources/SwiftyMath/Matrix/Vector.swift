//
//  Vector.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias _ColVector<n: _Int, R: Ring> = _Matrix<n, _1, R>
public typealias _RowVector<n: _Int, R: Ring> = _Matrix<_1, n, R>

public typealias ColVector<R: Ring> = _ColVector<Dynamic, R>
public typealias RowVector<R: Ring> = _RowVector<Dynamic, R>

public typealias Vector<R: Ring>  = ColVector<R>
public typealias Vector2<R: Ring> = _ColVector<_2, R>
public typealias Vector3<R: Ring> = _ColVector<_3, R>
public typealias Vector4<R: Ring> = _ColVector<_4, R>


public extension _Matrix where m == _1 {
    subscript(index: Int) -> R {
        @_transparent
        get { return self[index, 0] }
        
        @_transparent
        set { self[index, 0] = newValue }
    }
}

public extension _Matrix where n == _1 {
    subscript(index: Int) -> R {
        @_transparent
        get { return self[0, index] }
        
        @_transparent
        set { self[0, index] = newValue }
    }
}

public extension _Matrix where n == Dynamic, m == _1 {
    init(size: Int, generator g: (Int) -> R) {
        self.init(MatrixImpl(rows: size, cols: 1, generator: { (i, _) in g(i) }))
    }
}

public extension _Matrix where n == _1, m == Dynamic {
    init(size: Int, generator g: (Int) -> R) {
        self.init(MatrixImpl(rows: 1, cols: size, generator: { (_, j) in g(j) }))
    }
}
