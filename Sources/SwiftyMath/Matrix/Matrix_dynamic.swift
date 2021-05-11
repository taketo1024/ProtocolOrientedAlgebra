//
//  File.swift
//  
//
//  Created by Taketo Sano on 2021/05/11.
//

import Foundation

extension Matrix where n == DynamicSize, m == DynamicSize {
    public init(size: (Int, Int), initializer: ( (Int, Int, R) -> Void ) -> Void) {
        self.init(impl: Impl(size: size, initializer: initializer))
    }

    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == R {
        self.init(impl: Impl(size: size, grid: grid))
    }
    
    public static func zero(size: (Int, Int)) -> Self {
        self.init(impl: Impl.zero(size: size))
    }
    
    public static func identity(size n: Int) -> Self {
        self.init(impl: Impl.identity(size: (n, n)))
    }
    
    public static func unit(size: (Int, Int), at: (Int, Int)) -> Self {
        self.init(impl: Impl.unit(size: size, at: at))
    }
    
    public func pow(_ p: 𝐙) -> Self {
        assert(isSquare)
        assert(p >= 0)
        
        let I = DMatrix<R>.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
    }
}

extension Matrix where n == DynamicSize, m == _1 { // DColVector
    public init(_ grid: [R]) {
        self.init(impl: Impl.init(size: (grid.count, 1), grid: grid))
    }
    
    static func zero(size n: Int) -> Self {
        self.init(impl: Impl.zero(size: (n, 1)))
    }
    
    static func unit(size n: Int, at i: Int) -> Self {
        self.init(impl: Impl.unit(size: (n, 1), at: (i, 0)))
    }
}

extension Matrix where n == _1, m == DynamicSize { // DRowVector
    public init(_ grid: [R]) {
        self.init(impl: Impl.init(size: (1, grid.count), grid: grid))
    }
    
    static func zero(size m: Int) -> Self {
        self.init(impl: Impl.zero(size: (1, m)))
    }
    
    static func unit(size m: Int, at j: Int) -> Self {
        self.init(impl: Impl.unit(size: (1, m), at: (0, j)))
    }
}

