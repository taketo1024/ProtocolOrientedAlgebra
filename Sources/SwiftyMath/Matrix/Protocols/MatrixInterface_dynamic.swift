//
//  File.swift
//  
//
//  Created by Taketo Sano on 2021/05/11.
//

import Foundation

extension MatrixInterface where n == DynamicSize, m == DynamicSize {
    public init(size: (Int, Int), initializer: ( (Int, Int, BaseRing) -> Void ) -> Void) {
        self.init(Impl(size: size, initializer: initializer))
    }

    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == BaseRing {
        self.init(Impl(size: size, grid: grid))
    }
    
    public static func zero(size: (Int, Int)) -> Self {
        self.init(Impl.zero(size: size))
    }
    
    public static func identity(size n: Int) -> Self {
        self.init(Impl.identity(size: (n, n)))
    }
    
    public static func unit(size: (Int, Int), at: (Int, Int)) -> Self {
        self.init(Impl.unit(size: size, at: at))
    }
    
    public func pow(_ p: 𝐙) -> Self {
        assert(isSquare)
        assert(p >= 0)
        
        let I = Self.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
    }
}

extension MatrixInterface where n == DynamicSize, m == _1 { // DColVector
    public init(size n: Int, initializer s: @escaping ((Int, BaseRing) -> Void) -> Void) {
        self.init(Impl(size: (n, 1)) { setEntry in
            s { (i, a) in
                setEntry(i, 0, a)
            }
        })
    }
    
    public init(_ grid: [BaseRing]) {
        self.init(Impl.init(size: (grid.count, 1), grid: grid))
    }
    
    public static func zero(size n: Int) -> Self {
        self.init(Impl.zero(size: (n, 1)))
    }
    
    public static func unit(size n: Int, at i: Int) -> Self {
        self.init(Impl.unit(size: (n, 1), at: (i, 0)))
    }
}

extension MatrixInterface where n == _1, m == DynamicSize { // DRowVector
    public init(size m: Int, initializer s: @escaping ((Int, BaseRing) -> Void) -> Void) {
        self.init(Impl(size: (1, m)) { setEntry in
            s { (j, a) in
                setEntry(0, j, a)
            }
        })
    }
    
    public init(_ grid: [BaseRing]) {
        self.init(Impl.init(size: (1, grid.count), grid: grid))
    }
    
    public static func zero(size m: Int) -> Self {
        self.init(Impl.zero(size: (1, m)))
    }
    
    public static func unit(size m: Int, at j: Int) -> Self {
        self.init(Impl.unit(size: (1, m), at: (0, j)))
    }
}
