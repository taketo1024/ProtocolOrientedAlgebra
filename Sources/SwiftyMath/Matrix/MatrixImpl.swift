//
//  MatrixImpl.swift
//  Sample
//
//  Created by Taketo Sano on 2019/10/04.
//

public protocol MatrixImpl: CustomStringConvertible {
    associatedtype BaseRing: Ring
    typealias Initializer = (Int, Int, BaseRing) -> Void
    
    init(size: MatrixSize, initializer: (Initializer) -> Void)
    init<S: Sequence>(size: MatrixSize, grid: S) where S.Element == BaseRing
    init<S: Sequence>(size: MatrixSize, entries: S) where S.Element == MatrixEntry<BaseRing>

    static func zero(size: MatrixSize) -> Self
    static func identity(size: MatrixSize) -> Self
    static func unit(size: MatrixSize, at: (Int, Int)) -> Self
    static func scalar(size: MatrixSize, value: BaseRing) -> Self

    subscript(i: Int, j: Int) -> BaseRing { get set }
    var size: (rows: Int, cols: Int) { get }
    var isZero: Bool { get }
    var transposed: Self { get }
    var isInvertible: Bool { get }
    var inverse: Self? { get }
    var determinant: BaseRing { get }
    var trace: BaseRing { get }

    func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> Self
    func concat(_ B: Self) -> Self
    func stack(_ B: Self) -> Self
    func permuteRows(by σ: Permutation<DynamicSize>) -> Self
    func permuteCols(by σ: Permutation<DynamicSize>) -> Self
    
    static func ==(a: Self, b: Self) -> Bool
    static func +(a: Self, b: Self) -> Self
    static prefix func -(a: Self) -> Self
    static func -(a: Self, b: Self) -> Self
    static func *(r: BaseRing, a: Self) -> Self
    static func *(a: Self, r: BaseRing) -> Self
    static func *(a: Self, b: Self) -> Self
    static func ⊕(a: Self, B: Self) -> Self
    static func ⊗(a: Self, B: Self) -> Self

    var entries: AnySequence<MatrixEntry<BaseRing>> { get }
    var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> { get }
    func serialize() -> [BaseRing]

    var detailDescription: String { get }
}

extension MatrixImpl {
    public init<S: Sequence>(size: MatrixSize, grid: S) where S.Element == BaseRing {
        let m = size.cols
        self.init(size: size, entries: grid.enumerated().lazy.compactMap{ (idx, a) in
            if !a.isZero {
                let (i, j) = (idx / m, idx % m)
                return (i, j, a)
            } else {
                return nil
            }
        })
    }
    
    public init<S: Sequence>(size: MatrixSize, entries: S) where S.Element == MatrixEntry<BaseRing> {
        self.init(size: size) { setEntry in
            entries.forEach { (i, j, a) in setEntry(i, j, a) }
        }
    }
    
    public static func zero(size: MatrixSize) -> Self {
        .init(size: size) { _ in () }
    }
    
    public static func identity(size: MatrixSize) -> Self {
        scalar(size: size, value: .identity)
    }
    
    public static func unit(size: MatrixSize, at: (Int, Int)) -> Self {
        .init(size: size) { setEntry in
            setEntry(at.0, at.1, .identity)
        }
    }
    
    public static func scalar(size: MatrixSize, value: BaseRing) -> Self {
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
    
    public var entries: AnySequence<MatrixEntry<BaseRing>> {
        AnySequence((0 ..< size.rows).lazy.flatMap{ i in
            (0 ..< size.cols).lazy.map { j in
                (i, j, self[i, j])
            }
        })
    }
    
    public var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> {
        AnySequence((0 ..< size.rows).lazy.flatMap{ i in
            (0 ..< size.cols).lazy.compactMap { j in
                let a = self[i, j]
                return a.isZero ? nil : (i, j, a)
            }
        })
    }

    public var description: String {
        "[" + (0 ..< size.rows).map({ i in
            return (0 ..< size.cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public var detailDescription: String {
        if size.rows == 0 || size.cols == 0 {
            return "[\(size)]"
        } else {
            return "[\t" + (0 ..< size.rows).map({ i in
                (0 ..< size.cols).map({ j in
                    "\(self[i, j])"
                }).joined(separator: ",\t")
            }).joined(separator: "\n\t") + "]"
        }
    }
}

public protocol SparseMatrixImpl: MatrixImpl {
    var numberOfNonZeros: Int { get }
    
    @available(*, deprecated)
    var nonZeroComponents: AnySequence<MatrixEntry<BaseRing>> { get }
}
