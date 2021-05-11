//
//  MatrixIntf_static.swift
//  
//
//  Created by Taketo Sano on 2021/05/11.
//

extension Matrix: AdditiveGroup, Module, ExpressibleByArrayLiteral where n: StaticSizeType, m: StaticSizeType {
    public typealias ArrayLiteralElement = BaseRing
    
    public static var size: (rows: Int, cols: Int) {
        (n.intValue, m.intValue)
    }
    
    public init(initializer: @escaping (Initializer) -> Void) {
        self.init(impl: Impl.init(size: Self.size, initializer: initializer))
    }
    
    public init<S: Sequence>(grid: S) where S.Element == R {
        self.init(impl: Impl.init(size: Self.size, grid: grid))
    }
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(grid: elements)
    }

    public static var zero: Self {
        self.init(impl: Impl.zero(size: Self.size))
    }
    
    public static func unit(_ i: Int, _ j: Int) -> Self {
        self.init(impl: Impl.unit(size: Self.size, at: (i, j)))
    }
}

extension Matrix: Multiplicative, Monoid, Ring where n == m, n: StaticSizeType {
    public init(from a : 𝐙) {
        self.init(impl: Impl.scalar(size: Self.size, value: R.init(from: a)))
    }
    
    public static func identity(_ a: R) -> Self {
        self.init(impl: Impl.identity(size: Self.size))
    }

    public static func scalar(_ a: R) -> Self {
        self.init(impl: Impl.scalar(size: Self.size, value: a))
    }

    public var isInvertible: Bool {
        impl.isInvertible
    }
    
    public var inverse: Self? {
        impl.inverse.flatMap{ .init(impl: $0) }
    }
    
    public var determinant: R {
        impl.determinant
    }

    public var trace: R {
        diagonalComponents.sumAll()
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        self[0, 0]
    }
}

