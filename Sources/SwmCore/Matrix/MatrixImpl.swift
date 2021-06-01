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
    var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> { get }
    
    var isZero: Bool { get }
    var isIdentity: Bool { get }
    var isInvertible: Bool { get }
    var inverse: Self? { get }
    var determinant: BaseRing { get }
    var trace: BaseRing { get }

    var transposed: Self { get }
    func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> Self
    func concat(_ B: Self) -> Self
    func stack(_ B: Self) -> Self
    
    func permuteRows(by p: Permutation<anySize>) -> Self
    func permuteCols(by q: Permutation<anySize>) -> Self
    func permute(rowsBy p: Permutation<anySize>, colsBy q: Permutation<anySize>) -> Self

    func serialize() -> [BaseRing]

    static func ==(a: Self, b: Self) -> Bool
    static func +(a: Self, b: Self) -> Self
    static prefix func -(a: Self) -> Self
    static func -(a: Self, b: Self) -> Self
    static func *(r: BaseRing, a: Self) -> Self
    static func *(a: Self, r: BaseRing) -> Self
    static func *(a: Self, b: Self) -> Self
    static func ⊕(a: Self, b: Self) -> Self
    static func ⊗(a: Self, b: Self) -> Self
}

// MEMO: default implementations are provided,
// but conforming types should override them for performance.

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
    
    public var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> {
        AnySequence(
            ((0 ..< size.rows) * (0 ..< size.cols)).compactMap{ (i, j) in
                let a = self[i, j]
                return a.isZero ? nil : (i, j, a)
            }
        )
    }
    
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var isZero: Bool {
        nonZeroEntries.isEmpty
    }
    
    public var isIdentity: Bool {
        isSquare && nonZeroEntries.allSatisfy { (i, j, a) in i == j && a.isIdentity }
    }
    
    public var isInvertible: Bool {
        isSquare && determinant.isInvertible
    }
    
    public var inverse: Self? {
        if isSquare, let dInv = determinant.inverse {
            return .init(size: size) { setEntry in
                ((0 ..< size.rows) * (0 ..< size.cols)).forEach { (i, j) in
                    let a = dInv * cofactor(j, i)
                    setEntry(i, j, a)
                }
            }
        } else {
            return nil
        }
    }
    
    public var trace: BaseRing {
        assert(isSquare)
        return (0 ..< size.rows).sum { i in
            self[i, i]
        }
    }
    
    public var determinant: BaseRing {
        assert(isSquare)
        if size.rows == 0 {
            return .identity
        } else {
            return nonZeroEntries
                .filter{ (i, j, a) in i == 0 }
                .sum { (_, j, a) in a * cofactor(0, j) }
        }
    }
    
    private func cofactor(_ i0: Int, _ j0: Int) -> BaseRing {
        let ε = (-BaseRing.identity).pow(i0 + j0)
        let minor = Self(size: (size.rows - 1, size.cols - 1)) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in
                if i == i0 || j == j0 { return }
                let i1 = i < i0 ? i : i - 1
                let j1 = j < j0 ? j : j - 1
                setEntry(i1, j1, a)
            }
        }
        return ε * minor.determinant
    }
    
    public var transposed: Self {
        .init(size: (size.cols, size.rows)) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in setEntry(j, i, a) }
        }
    }
    
    public func submatrix(rowRange: CountableRange<Int>, colRange: CountableRange<Int>) -> Self {
        let size = (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound)
        return .init(size: size ) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in
                if rowRange.contains(i) && colRange.contains(j) {
                    setEntry(i - rowRange.lowerBound, j - colRange.lowerBound, a)
                }
            }
        }
    }
    
    public func concat(_ B: Self) -> Self {
        assert(size.rows == B.size.rows)
        
        let A = self
        return .init(size: (A.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j + A.size.cols, a) }
        }
    }
    
    public func stack(_ B: Self) -> Self {
        assert(size.cols == B.size.cols)
        
        let A = self
        return .init(size: (A.size.rows + B.size.rows, A.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i + A.size.rows, j, a) }
        }
    }
    
    public func permuteRows(by p: Permutation<anySize>) -> Self {
        permute(rowsBy: p, colsBy: .identity(length: size.cols))
    }
    
    public func permuteCols(by q: Permutation<anySize>) -> Self {
        permute(rowsBy: .identity(length: size.rows), colsBy: q)
    }

    public func permute(rowsBy p: Permutation<anySize>, colsBy q: Permutation<anySize>) -> Self {
        .init(size: size) { setEntry in
            nonZeroEntries.forEach{ (i, j, a) in
                setEntry(p[i], q[j], a)
            }
        }
    }

    public static func ⊕ (A: Self, B: Self) -> Self {
        .init(size: (A.size.rows + B.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i + A.size.rows, j + A.size.cols, a) }
        }
    }
    
    public static func ⊗ (A: Self, B: Self) -> Self {
        .init(size: (A.size.rows * B.size.rows, A.size.cols * B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in
                B.nonZeroEntries.forEach { (k, l, b) in
                    let p = i * B.size.rows + k
                    let q = j * B.size.cols + l
                    let c = a * b
                    setEntry(p, q, c)
                }
            }
        }
    }
    
    public func serialize() -> [BaseRing] {
        ((0 ..< size.rows) * (0 ..< size.cols)).map{ (i, j) in
            self[i, j]
        }
    }
    
    public var description: String {
        "[" + (0 ..< size.rows).map({ i in
            (0 ..< size.cols).map({ j in
                "\(self[i, j])"
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
}
