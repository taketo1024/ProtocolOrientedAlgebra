//
//  Vector.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias ColVector<n: SizeType, R: Ring> = Matrix<n, _1, R>
public typealias RowVector<m: SizeType, R: Ring> = Matrix<_1, m, R>

public typealias DRowVector<R: Ring> = RowVector<DynamicSize, R>
public typealias DColVector<R: Ring> = ColVector<DynamicSize, R>
public typealias DVector<R: Ring>    = DColVector<R>

public typealias Vector2<R: Ring> = ColVector<_2, R>
public typealias Vector3<R: Ring> = ColVector<_3, R>
public typealias Vector4<R: Ring> = ColVector<_4, R>


public extension Matrix where m == _1 { // (D)ColVector
    subscript(index: Int) -> R {
        @_transparent
        get { return self[index, 0] }
        
        @_transparent
        set { self[index, 0] = newValue }
    }
}

public extension Matrix where n == _1 { // (D)RowVector
    subscript(index: Int) -> R {
        @_transparent
        get { return self[0, index] }
        
        @_transparent
        set { self[0, index] = newValue }
    }
}

public extension Matrix where n: StaticSizeType, m == _1 {
    var asDynamic: DColVector<R> {
        return DColVector(impl)
    }
}

public extension Matrix where n == _1, m: StaticSizeType {
    var asDynamic: DRowVector<R> {
        return DRowVector(impl)
    }
}

public extension Matrix where n == DynamicSize, m == _1 { // DColVector
    init(_ grid: [R]) {
        self.init(MatrixImpl(rows: grid.count, cols: 1, grid: grid))
    }
    
    init(_ grid: R...) {
        self.init(grid)
    }

    init(size: Int, generator g: (Int) -> R) {
        self.init(MatrixImpl(rows: size, cols: 1, generator: { (i, _) in g(i) }))
    }
    
    init(size: Int, components: [MatrixComponent<R>]) {
        self.init(MatrixImpl(rows: size, cols: 1, components: components))
    }
    
    func `as`<n>(_ type: ColVector<n, R>.Type) -> ColVector<n, R> {
        assert(n.isDynamic || n.intValue == rows)
        return ColVector<n, R>(impl)
    }
}

public extension Matrix where n == _1, m == DynamicSize { // DRowVector
    init(_ grid: [R]) {
        self.init(MatrixImpl(rows: 1, cols: grid.count, grid: grid))
    }
    
    init(_ grid: R...) {
        self.init(grid)
    }

    init(size: Int, generator g: (Int) -> R) {
        self.init(MatrixImpl(rows: 1, cols: size, generator: { (_, j) in g(j) }))
    }
    
    init(size: Int, components: [MatrixComponent<R>]) {
        self.init(MatrixImpl(rows: 1, cols: size, components: components))
    }
    
    func `as`<m>(_ type: RowVector<m, R>.Type) -> RowVector<m, R> {
        assert(m.isDynamic || m.intValue == rows)
        return RowVector<m, R>(impl)
    }
}
