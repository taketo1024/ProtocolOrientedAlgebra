//
//  MatrixInterafce.swift
//
//
//  Created by Taketo Sano.
//

public typealias ColVectorIF<Impl: MatrixImpl, n: SizeType> = MatrixIF<Impl, n, _1>
public typealias RowVectorIF<Impl: MatrixImpl, m: SizeType> = MatrixIF<Impl, _1, m>

public typealias AnySizeMatrixIF<Impl: MatrixImpl> = MatrixIF<Impl, anySize, anySize>
public typealias AnySizeColVectorIF<Impl: MatrixImpl> = ColVectorIF<Impl, anySize>
public typealias AnySizeRowVectorIF<Impl: MatrixImpl> = RowVectorIF<Impl, anySize>

public struct MatrixIF<Impl: MatrixImpl, n: SizeType, m: SizeType>: MathSet {
    public typealias BaseRing = Impl.BaseRing
    public typealias Initializer = Impl.Initializer
    
    public var impl: Impl
    
    public init(_ impl: Impl) {
        assert(n.isArbitrary || n.intValue == impl.size.rows)
        assert(m.isArbitrary || m.intValue == impl.size.cols)
        self.impl = impl
    }
    
    @inlinable
    public init(size: MatrixSize, initializer: ( (Int, Int, BaseRing) -> Void ) -> Void) {
        self.init(Impl(size: size, initializer: initializer))
    }

    @inlinable
    public init<S: Sequence>(size: MatrixSize, grid: S) where S.Element == BaseRing {
        self.init(Impl(size: size, grid: grid))
    }
    
    @inlinable
    public init<S: Sequence>(size: MatrixSize, entries: S) where S.Element == MatrixEntry<BaseRing> {
        self.init(Impl(size: size, entries: entries))
    }
    
    @inlinable
    public static func zero(size: MatrixSize) -> Self {
        self.init(Impl.zero(size: size))
    }
    
    @inlinable
    public static func identity(size: MatrixSize) -> Self {
        self.init(Impl.identity(size: size))
    }
    
    @inlinable
    public static func unit(size: MatrixSize, at: (Int, Int)) -> Self {
        self.init(Impl.unit(size: size, at: at))
    }
    
    @inlinable
    public subscript(i: Int, j: Int) -> BaseRing {
        get {
            impl[i, j]
        } set {
            impl[i, j] = newValue
        }
    }
    
    @inlinable
    public subscript(rowRange: Range<Int>, colRange: Range<Int>) -> MatrixIF<Impl, anySize, anySize> {
        self.submatrix(rowRange: rowRange, colRange: colRange)
    }

    @inlinable
    public var size: (rows: Int, cols: Int) {
        impl.size
    }
    
    @inlinable
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    @inlinable
    public var isZero: Bool {
        impl.isZero
    }
    
    @inlinable
    public var isIdentity: Bool {
        impl.isIdentity
    }
    
    @inlinable
    public var transposed: MatrixIF<Impl, m, n> {
        .init(impl.transposed)
    }
    
    @inlinable
    public func rowVector(_ i: Int) -> MatrixIF<Impl, _1, m> {
        .init(impl.rowVector(i))
    }
    
    @inlinable
    public func colVector(_ j: Int) -> MatrixIF<Impl, n, _1> {
        .init(impl.colVector(j))
    }
    
    @inlinable
    public func submatrix(rowRange: CountableRange<Int>) -> MatrixIF<Impl, anySize, m> {
        .init(impl.submatrix(rowRange: rowRange))
    }
    
    @inlinable
    public func submatrix(colRange: CountableRange<Int>) -> MatrixIF<Impl, n, anySize> {
        .init(impl.submatrix(colRange: colRange))
    }
    
    @inlinable
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixIF<Impl, anySize, anySize> {
        .init(impl.submatrix(rowRange: rowRange, colRange: colRange))
    }
    
    @inlinable
    public func concat<m1>(_ B: MatrixIF<Impl, n, m1>) -> MatrixIF<Impl, n, anySize> {
        .init(impl.concat(B.impl))
    }
    
    @inlinable
    public func stack<n1>(_ B: MatrixIF<Impl, n1, m>) -> MatrixIF<Impl, anySize, m> {
        .init(impl.stack(B.impl))
    }
    
    @inlinable
    public func permuteRows(by p: Permutation<n>) -> Self {
        .init(impl.permuteRows(by: p.asAnySize))
    }
    
    @inlinable
    public func permuteCols(by q: Permutation<m>) -> Self {
        .init(impl.permuteCols(by: q.asAnySize))
    }
    
    @inlinable
    public func permute(rowsBy p: Permutation<n>, colsBy q: Permutation<m>) -> Self {
        .init(impl.permute(rowsBy: p.asAnySize, colsBy: q.asAnySize))
    }
    
    @inlinable
    public func serialize() -> [BaseRing] {
        impl.serialize()
    }
    
    @inlinable
    public static func ==(a: Self, b: Self) -> Bool {
        a.impl == b.impl
    }
    
    @inlinable
    public static func +(a: Self, b: Self) -> Self {
        .init(a.impl + b.impl)
    }
    
    @inlinable
    public prefix static func -(a: Self) -> Self {
        .init(-a.impl)
    }
    
    @inlinable
    public static func -(a: Self, b: Self) -> Self {
        .init(a.impl - b.impl)
    }
    
    @inlinable
    public static func *(r: BaseRing, a: Self) -> Self {
        .init(r * a.impl)
    }
    
    @inlinable
    public static func *(a: Self, r: BaseRing) -> Self {
        .init(a.impl * r)
    }
    
    @inlinable
    public static func * <p>(a: MatrixIF<Impl, n, m>, b: MatrixIF<Impl, m, p>) -> MatrixIF<Impl, n, p> {
        .init(a.impl * b.impl)
    }
    
    @inlinable
    public static func ⊕ <n1, m1>(A: MatrixIF<Impl, n, m>, B: MatrixIF<Impl, n1, m1>) -> MatrixIF<Impl, anySize, anySize> {
        .init(A.impl ⊕ B.impl)
    }
    
    @inlinable
    public static func ⊗ <n1, m1>(A: MatrixIF<Impl, n, m>, B: MatrixIF<Impl, n1, m1>) -> MatrixIF<Impl, anySize, anySize> {
        .init(A.impl ⊗ B.impl)
    }
    
    @inlinable
    public static func *(p: Permutation<n>, a: Self) -> Self {
        a.permuteRows(by: p)
    }
    
    @inlinable
    public static func *(a: Self, p: Permutation<m>) -> Self {
        a.permuteCols(by: p)
    }
    
    @inlinable
    public func `as`<n1, m1>(_ type: MatrixIF<Impl, n1, m1>.Type) -> MatrixIF<Impl, n1, m1> {
        MatrixIF<Impl, n1, m1>(impl)
    }
    
    @inlinable
    public var asAnySizeMatrix: AnySizeMatrixIF<Impl> {
        `as`(AnySizeMatrixIF.self)
    }
    
    @inlinable
    public func convert<OtherImpl, n1, m1>(to type: MatrixIF<OtherImpl, n1, m1>.Type) -> MatrixIF<OtherImpl, n1, m1>
    where OtherImpl.BaseRing == BaseRing {
        .init(OtherImpl.init(size: size, entries: nonZeroEntries))
    }
    
    @inlinable
    public var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> {
        impl.nonZeroEntries
    }
    
    @inlinable
    public func mapNonZeroEntries(_ f: @escaping (Int, Int, BaseRing) -> BaseRing) -> Self {
        .init(impl.mapNonZeroEntries(f))
    }
    
    @inlinable
    public var description: String {
        impl.description
    }
    
    @inlinable
    public var detailDescription: String {
        impl.detailDescription
    }
    
    public static var symbol: String {
        func str(_ t: SizeType.Type) -> String {
            t.isFixed ? "\(t.intValue)" : "any"
        }
        if m.intValue == 1 {
            return "ColVec<\(BaseRing.symbol); \(str(n.self))>"
        }
        if n.intValue == 1 {
            return "RowVec<\(BaseRing.symbol); \(str(n.self))>"
        }
        return "Mat<\(BaseRing.symbol); \(str(n.self)), \(str(n.self))>"
    }
}

// MARK: Square Matrix

extension MatrixIF where n == m { // n, m: possibly anySize
    @inlinable
    public var isInvertible: Bool {
        impl.isInvertible
    }
    
    @inlinable
    public var inverse: Self? {
        impl.inverse.flatMap{ .init($0) }
    }
    
    @inlinable
    public var determinant: BaseRing {
        impl.determinant
    }

    @inlinable
    public var trace: BaseRing {
        impl.trace
    }
}

// MARK: ColVector

extension MatrixIF where m == _1 { // n: possibly anySize
    public typealias ColInitializer = (Int, BaseRing) -> Void
    public init(size n: Int, initializer s: @escaping (ColInitializer) -> Void) {
        self.init(Impl(size: (n, 1)) { setEntry in
            s { (i, a) in
                setEntry(i, 0, a)
            }
        })
    }
    
    @inlinable
    public init(size n: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (n, 1), grid: grid))
    }
    
    @inlinable
    public init<S: Sequence>(size n: Int, colEntries: S) where S.Element == ColEntry<BaseRing> {
        self.init(size: (n, 1), entries: colEntries.map{ (i, a) in MatrixEntry(i, 0, a) })
    }

    @inlinable
    public static func zero(size n: Int) -> Self {
        .init(Impl.zero(size: (n, 1)))
    }
    
    @inlinable
    public static func unit(size n: Int, at i: Int) -> Self {
        .init(Impl.unit(size: (n, 1), at: (i, 0)))
    }

    @inlinable
    public subscript(index: Int) -> BaseRing {
        get {
            self[index, 0]
        } set {
            self[index, 0] = newValue
        }
    }
    
    @inlinable
    public subscript(range: Range<Int>) -> MatrixIF<Impl, anySize, _1> {
        submatrix(rowRange: range)
    }
    
    @inlinable
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
    
    @inlinable
    public var nonZeroColEntries: AnySequence<ColEntry<BaseRing>> {
        AnySequence(nonZeroEntries.lazy.map{ (i, _, a) in (i, a)})
    }
    
    @inlinable
    public var asAnySizeColVector: AnySizeColVectorIF<Impl> {
        `as`(AnySizeColVectorIF.self)
    }
}

// MARK: RowVector

extension MatrixIF where n == _1 { // m: possibly anySize
    public typealias RowInitializer = (Int, BaseRing) -> Void
    public init(size m: Int, initializer s: @escaping (RowInitializer) -> Void) {
        self.init(Impl(size: (1, m)) { setEntry in
            s { (j, a) in
                setEntry(0, j, a)
            }
        })
    }
    
    @inlinable
    public init(size m: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (1, m), grid: grid))
    }
    
    @inlinable
    public init<S: Sequence>(size m: Int, rowEntries: S) where S.Element == RowEntry<BaseRing> {
        self.init(size: (1, m), entries: rowEntries.map{ (j, a) in MatrixEntry(0, j, a) })
    }

    @inlinable
    public static func zero(size m: Int) -> Self {
        .init(Impl.zero(size: (1, m)))
    }
    
    @inlinable
    public static func unit(size m: Int, at j: Int) -> Self {
        .init(Impl.unit(size: (1, m), at: (0, j)))
    }
    
    @inlinable
    public subscript(index: Int) -> BaseRing {
        get {
            self[0, index]
        } set {
            self[0, index] = newValue
        }
    }
    
    @inlinable
    public subscript(range: Range<Int>) -> MatrixIF<Impl, _1, anySize> {
        submatrix(colRange: range)
    }
    
    @inlinable
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
    
    @inlinable
    public var nonZeroRowEntries: AnySequence<RowEntry<BaseRing>> {
        AnySequence(nonZeroEntries.lazy.map{ (_, j, a) in (j, a)})
    }
    
    @inlinable
    public var asAnySizeRowVector: AnySizeRowVectorIF<Impl> {
        `as`(AnySizeRowVectorIF.self)
    }
}

// MARK: Fixed-size Matrix

extension MatrixIF: AdditiveGroup, Module, ExpressibleByArrayLiteral where n: FixedSizeType, m: FixedSizeType {
    public typealias ArrayLiteralElement = BaseRing
    
    @inlinable
    public static var size: MatrixSize {
        (n.intValue, m.intValue)
    }
    
    @inlinable
    public init(initializer: @escaping (Initializer) -> Void) {
        self.init(size: Self.size, initializer: initializer)
    }
    
    @inlinable
    public init<S: Sequence>(grid: S) where S.Element == BaseRing {
        self.init(size: Self.size, grid: grid)
    }
    
    @inlinable
    public init<S: Sequence>(entries: S) where S.Element == MatrixEntry<BaseRing> {
        self.init(size: Self.size, entries: entries)
    }
    
    @inlinable
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(grid: elements)
    }

    @inlinable
    public static var zero: Self {
        .zero(size: Self.size)
    }
    
    @inlinable
    public static var identity: Self {
        .identity(size: Self.size)
    }

    @inlinable
    public static func scalar(_ a: BaseRing) -> Self {
        .init(Impl.scalar(size: Self.size, value: a))
    }

    @inlinable
    public static func unit(_ i: Int, _ j: Int) -> Self {
        .unit(size: Self.size, at: (i, j))
    }
    
    public static func diagonal(_ entries: BaseRing...) -> Self {
        self.init { setEntry in
            entries.enumerated().forEach { (i, a) in
                setEntry(i, i, a)
            }
        }
    }
}

// MARK: Fixed-size Square Matrix

extension MatrixIF: Multiplicative, Monoid, Ring where n == m, n: FixedSizeType {
    @inlinable
    public init(from a : 𝐙) {
        self.init(Impl.scalar(size: Self.size, value: BaseRing.init(from: a)))
    }
    
    @inlinable
    public var isInvertible: Bool {
        impl.isInvertible
    }
    
    @inlinable
    public var inverse: Self? {
        impl.inverse.flatMap{ .init($0) }
    }
    
    @inlinable
    public var determinant: BaseRing {
        impl.determinant
    }

    @inlinable
    public var trace: BaseRing {
        impl.trace
    }
}

// MARK: Fixed-size ColVector

extension MatrixIF where n: FixedSizeType, m == _1 {
    public init(initializer s: @escaping (ColInitializer) -> Void) {
        self.init { setEntry in
            s { (i, a) in
                setEntry(i, 0, a)
            }
        }
    }
}

// MARK: Fixed-size RowVector

extension MatrixIF where n == _1, m: FixedSizeType {
    public init(initializer s: @escaping (RowInitializer) -> Void) {
        self.init { setEntry in
            s { (j, a) in
                setEntry(0, j, a)
            }
        }
    }
}

// MARK: 1x1 Matrix

extension MatrixIF where n == m, n == _1 {
    @inlinable
    public var asScalar: BaseRing {
        self[0, 0]
    }
}

// MARK: Random

extension MatrixIF where BaseRing: Randomable {
    public static func random(size: MatrixSize) -> Self {
        .init(size: size, grid: (0 ..< size.rows * size.cols).map{_ in .random() } )
    }
}

extension MatrixIF where BaseRing: RangeRandomable {
    public static func random(size: MatrixSize, in range: Range<BaseRing.RangeBound>) -> Self {
        .init(size: size, grid: (0 ..< size.rows * size.cols).map{_ in .random(in: range) } )
    }

    public static func random(size: MatrixSize, in range: ClosedRange<BaseRing.RangeBound>) -> Self {
        .init(size: size, grid: (0 ..< size.rows * size.cols).map{_ in .random(in: range) } )
    }
}

extension MatrixIF: Randomable where BaseRing: Randomable, n: FixedSizeType, m: FixedSizeType {
    public static func random() -> MatrixIF<Impl, n, m> {
        random(size: Self.size)
    }
}

extension MatrixIF: RangeRandomable where BaseRing: RangeRandomable, n: FixedSizeType, m: FixedSizeType {
    public static func random(in range: Range<BaseRing.RangeBound>) -> Self {
        random(size: Self.size, in: range)
    }

    public static func random(in range: ClosedRange<BaseRing.RangeBound>) -> Self {
        random(size: Self.size, in: range)
    }
}
