//
//  MatrixInterafce.swift
//
//
//  Created by Taketo Sano.
//

public struct MatrixIF<Impl: MatrixImpl, n: SizeType, m: SizeType>: MathSet {
    public typealias BaseRing = Impl.BaseRing
    public typealias Initializer = Impl.Initializer
    
    public var impl: Impl
    
    public init(_ impl: Impl) {
        assert(n.isArbitrary || n.intValue == impl.size.rows)
        assert(m.isArbitrary || m.intValue == impl.size.cols)
        self.impl = impl
    }
    
    public init(size: MatrixSize, initializer: ( (Int, Int, BaseRing) -> Void ) -> Void) {
        self.init(Impl(size: size, initializer: initializer))
    }

    public init<S: Sequence>(size: MatrixSize, grid: S) where S.Element == BaseRing {
        self.init(Impl(size: size, grid: grid))
    }
    
    public init<S: Sequence>(size: MatrixSize, entries: S) where S.Element == MatrixEntry<BaseRing> {
        self.init(Impl(size: size, entries: entries))
    }
    
    public init<OtherImpl>(_ other: MatrixIF<OtherImpl, n, m>) where OtherImpl.BaseRing == BaseRing {
        self.init(Impl.init(size: other.size, grid: other.serialize()))
    }
    
    public static func zero(size: MatrixSize) -> Self {
        self.init(Impl.zero(size: size))
    }
    
    public static func identity(size: MatrixSize) -> Self {
        self.init(Impl.identity(size: size))
    }
    
    public static func unit(size: MatrixSize, at: (Int, Int)) -> Self {
        self.init(Impl.unit(size: size, at: at))
    }
    
    public subscript(i: Int, j: Int) -> BaseRing {
        get {
            impl[i, j]
        } set {
            impl[i, j] = newValue
        }
    }
    
    public var size: (rows: Int, cols: Int) {
        impl.size
    }
    
    public var isZero: Bool {
        impl.isZero
    }
    
    public var isSquare: Bool {
        impl.isSquare
    }
    
    public var transposed: MatrixIF<Impl, m, n> {
        .init(impl.transposed)
    }
    
    public func rowVector(_ i: Int) -> MatrixIF<Impl, _1, m> {
        submatrix(rowRange: i ..< i + 1, colRange: 0 ..< size.cols)
            .as(MatrixIF<Impl, _1, m>.self)
    }
    
    public func colVector(_ j: Int) -> MatrixIF<Impl, n, _1> {
        submatrix(rowRange: 0 ..< size.rows, colRange: j ..< j + 1)
            .as(MatrixIF<Impl, n, _1>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> MatrixIF<Impl, anySize, m> {
        submatrix(rowRange: rowRange, colRange: 0 ..< size.cols)
            .as(MatrixIF<Impl, anySize, m>.self)
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> MatrixIF<Impl, n, anySize> {
        submatrix(rowRange: 0 ..< size.rows, colRange: colRange)
            .as(MatrixIF<Impl, n, anySize>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixIF<Impl, anySize, anySize> {
        .init(impl.submatrix(rowRange: rowRange, colRange: colRange))
    }
    
    public func concat<m1>(_ B: MatrixIF<Impl, n, m1>) -> MatrixIF<Impl, n, anySize> {
        .init(impl.concat(B.impl))
    }
    
    public func stack<n1>(_ B: MatrixIF<Impl, n1, m>) -> MatrixIF<Impl, anySize, m> {
        .init(impl.stack(B.impl))
    }
    
    public func permuteRows(by σ: Permutation<n>) -> Self {
        .init(impl.permuteRows(by: σ.asDynamic))
    }
    
    public func permuteCols(by σ: Permutation<m>) -> Self {
        .init(impl.permuteCols(by: σ.asDynamic))
    }
    
    public func serialize() -> [BaseRing] {
        impl.serialize()
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.impl == b.impl
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.impl + b.impl)
    }
    
    public prefix static func -(a: Self) -> Self {
        .init(-a.impl)
    }
    
    public static func -(a: Self, b: Self) -> Self {
        .init(a.impl - b.impl)
    }
    
    public static func *(r: BaseRing, a: Self) -> Self {
        .init(r * a.impl)
    }
    
    public static func *(a: Self, r: BaseRing) -> Self {
        .init(a.impl * r)
    }
    
    public static func * <p>(a: MatrixIF<Impl, n, m>, b: MatrixIF<Impl, m, p>) -> MatrixIF<Impl, n, p> {
        .init(a.impl * b.impl)
    }
    
    public static func ⊕ <n1, m1>(A: MatrixIF<Impl, n, m>, B: MatrixIF<Impl, n1, m1>) -> MatrixIF<Impl, anySize, anySize> {
        .init(A.impl ⊕ B.impl)
    }
    
    public static func ⊗ <n1, m1>(A: MatrixIF<Impl, n, m>, B: MatrixIF<Impl, n1, m1>) -> MatrixIF<Impl, anySize, anySize> {
        .init(A.impl ⊗ B.impl)
    }
    
    public static func *(σ: Permutation<n>, a: Self) -> Self {
        a.permuteRows(by: σ)
    }
    
    public static func *(a: Self, σ: Permutation<m>) -> Self {
        a.permuteCols(by: σ)
    }
    
    public func `as`<n1, m1>(_ type: MatrixIF<Impl, n1, m1>.Type) -> MatrixIF<Impl, n1, m1> {
        MatrixIF<Impl, n1, m1>(impl)
    }
    
    public var asDynamicMatrix: MatrixIF<Impl, anySize, anySize> {
        self.as(MatrixIF<Impl, anySize, anySize>.self)
    }
    
    public var entries: AnySequence<MatrixEntry<BaseRing>> {
        impl.entries
    }
    
    public var nonZeroEntries: AnySequence<MatrixEntry<BaseRing>> {
        impl.nonZeroEntries
    }
    
    public var description: String {
        impl.description
    }
    
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

// MARK: Sparse Matrix

extension MatrixIF where Impl: SparseMatrixImpl {
    public var numberOfNonZeros: Int {
        impl.numberOfNonZeros
    }
    
    @available(*, deprecated)
    public var nonZeroComponents: AnySequence<MatrixEntry<BaseRing>> {
        impl.nonZeroComponents
    }
}

// MARK: Square Matrix

extension MatrixIF where n == m { // n, m: possibly anySize
    public var isInvertible: Bool {
        isSquare && impl.isInvertible
    }
    
    public var inverse: Self? {
        isSquare ? impl.inverse.flatMap{ .init($0) } : nil
    }
    
    public var determinant: BaseRing {
        impl.determinant
    }

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
    
    public init(size n: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (n, 1), grid: grid))
    }
    
    public static func zero(size n: Int) -> Self {
        self.init(Impl.zero(size: (n, 1)))
    }
    
    public static func unit(size n: Int, at i: Int) -> Self {
        self.init(Impl.unit(size: (n, 1), at: (i, 0)))
    }

    public subscript(index: Int) -> BaseRing {
        get {
            self[index, 0]
        } set {
            self[index, 0] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
    
    public var colEntries: AnySequence<ColEntry<BaseRing>> {
        AnySequence(entries.lazy.map{ (i, _, a) in (i, a)})
    }
    
    public var nonZeroColEntries: AnySequence<ColEntry<BaseRing>> {
        AnySequence(nonZeroEntries.lazy.map{ (i, _, a) in (i, a)})
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
    
    public init(size m: Int, grid: [BaseRing]) {
        self.init(Impl.init(size: (1, m), grid: grid))
    }
    
    public static func zero(size m: Int) -> Self {
        self.init(Impl.zero(size: (1, m)))
    }
    
    public static func unit(size m: Int, at j: Int) -> Self {
        self.init(Impl.unit(size: (1, m), at: (0, j)))
    }
    
    public subscript(index: Int) -> BaseRing {
        get {
            self[0, index]
        } set {
            self[0, index] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> BaseRing {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
    
    public var rowEntries: AnySequence<RowEntry<BaseRing>> {
        AnySequence(entries.lazy.map{ (_, j, a) in (j, a)})
    }
    
    public var nonZeroRowEntries: AnySequence<RowEntry<BaseRing>> {
        AnySequence(nonZeroEntries.lazy.map{ (_, j, a) in (j, a)})
    }
}

// MARK: Fixed-size Matrix

extension MatrixIF: AdditiveGroup, Module, ExpressibleByArrayLiteral where n: FixedSizeType, m: FixedSizeType {
    public typealias ArrayLiteralElement = BaseRing
    
    public static var size: MatrixSize {
        (n.intValue, m.intValue)
    }
    
    public init(initializer: @escaping (Initializer) -> Void) {
        self.init(size: Self.size, initializer: initializer)
    }
    
    public init<S: Sequence>(grid: S) where S.Element == BaseRing {
        self.init(size: Self.size, grid: grid)
    }
    
    public init<S: Sequence>(entries: S) where S.Element == MatrixEntry<BaseRing> {
        self.init(size: Self.size, entries: entries)
    }
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(grid: elements)
    }

    public static var zero: Self {
        self.zero(size: Self.size)
    }
    
    public static var identity: Self {
        self.identity(size: Self.size)
    }

    public static func scalar(_ a: BaseRing) -> Self {
        self.init(Impl.scalar(size: Self.size, value: a))
    }

    public static func unit(_ i: Int, _ j: Int) -> Self {
        self.unit(size: Self.size, at: (i, j))
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
    public init(from a : 𝐙) {
        self.init(Impl.scalar(size: Self.size, value: BaseRing.init(from: a)))
    }
    
    public var isInvertible: Bool {
        impl.isInvertible
    }
    
    public var inverse: Self? {
        impl.inverse.flatMap{ .init($0) }
    }
    
    public var determinant: BaseRing {
        impl.determinant
    }

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
    public var asScalar: BaseRing {
        self[0, 0]
    }
}
