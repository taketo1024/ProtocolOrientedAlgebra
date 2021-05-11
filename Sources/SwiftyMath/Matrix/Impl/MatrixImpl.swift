//
//  MatrixImpl.swift
//  Sample
//
//  Created by Taketo Sano on 2019/10/04.
//

public protocol MatrixImpl: CustomStringConvertible {
    associatedtype BaseRing: Ring
    typealias Initializer = (Int, Int, BaseRing) -> Void
    
    init(size: (Int, Int), initializer: (Initializer) -> Void)
    init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == BaseRing

    static func zero(size: (Int, Int)) -> Self
    static func identity(size: (Int, Int)) -> Self
    static func unit(size: (Int, Int), at: (Int, Int)) -> Self
    static func scalar(size: (Int, Int), value: BaseRing) -> Self

    subscript(i: Int, j: Int) -> BaseRing { get set }
    var size: (rows: Int, cols: Int) { get }
    var isZero: Bool { get }
    var transposed: Self { get }
    var isInvertible: Bool { get }
    var inverse: Self? { get }
    var determinant: BaseRing { get }
    var trace: BaseRing { get }

    func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> Self
    func serialize() -> [BaseRing]
    
    static func ==(a: Self, b: Self) -> Bool
    static func +(a: Self, b: Self) -> Self
    static prefix func -(a: Self) -> Self
    static func -(a: Self, b: Self) -> Self
    static func *(r: BaseRing, a: Self) -> Self
    static func *(a: Self, r: BaseRing) -> Self
    static func *(a: Self, b: Self) -> Self
}

extension MatrixImpl {
    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == BaseRing {
        self.init(size: size) { setEntry in
            let m = size.1
            for (idx, a) in grid.enumerated() where !a.isZero {
                let (i, j) = (idx / m, idx % m)
                setEntry(i, j, a)
            }
        }
    }
    
    public static func zero(size: (Int, Int)) -> Self {
        .init(size: size) { _ in () }
    }
    
    public static func identity(size: (Int, Int)) -> Self {
        scalar(size: size, value: .identity)
    }
    
    public static func unit(size: (Int, Int), at: (Int, Int)) -> Self {
        .init(size: size) { setEntry in
            setEntry(at.0, at.1, .identity)
        }
    }
    
    public static func scalar(size: (Int, Int), value: BaseRing) -> Self {
        .init(size: size) { setEntry in
            let r = min(size.0, size.1)
            for i in 0 ..< r {
                setEntry(i, i, value)
            }
        }
    }
    
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var trace: BaseRing {
        assert(isSquare)
        return (0 ..< size.rows).sum { i in
            self[i, i]
        }
    }
    
    public static func -(a: Self, b: Self) -> Self {
        a + (-b)
    }
}
