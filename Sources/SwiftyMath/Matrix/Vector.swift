//
//  Vector.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

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
        get {
            self[index, 0]
        }
        @_transparent
        set {
            self[index, 0] = newValue
        }
    }
    
    static func zero(size: Int) -> Self {
        .init(size: (size, 1), grid: [])
    }
}

public extension Matrix where n == _1 { // (D)RowVector
    subscript(index: Int) -> R {
        @_transparent
        get {
            self[0, index]
        }
        @_transparent
        set {
            self[0, index] = newValue
        }
    }
    
    static func zero(size: Int) -> Self {
        .init(size: (1, size), grid: [])
    }
}

public extension Matrix where n == DynamicSize, m == _1 { // DColVector
    init(_ grid: [R]) {
        self.init(size: (grid.count, 1), grid: grid)
    }
    
    init(_ grid: R...) {
        self.init(grid)
    }
}

public extension Matrix where n == _1, m == DynamicSize { // DRowVector
    init(_ grid: [R]) {
        self.init(size: (1, grid.count), grid: grid)
    }
    
    init(_ grid: R...) {
        self.init(grid)
    }
}

public func •<n, R>(_ left: RowVector<n, R>, _ right: ColVector<n, R>) -> R {
    left.nonZeroComponents.sum{ (_, i, a) in a * right[i] }
}
