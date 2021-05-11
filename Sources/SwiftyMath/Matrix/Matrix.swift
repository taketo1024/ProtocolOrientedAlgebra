//
//  Matrix.swift
//
//
//  Created by Taketo Sano.
//

public typealias Matrix<n: SizeType, m: SizeType, R: Ring> = MatrixInterface<DefaultMatrixImpl<R>, n, m, R>
public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>

public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

public typealias ColVector<n: SizeType, R: Ring> = Matrix<n, _1, R>
public typealias RowVector<m: SizeType, R: Ring> = Matrix<_1, m, R>
public typealias Vector<n: SizeType, R: Ring> = ColVector<n, R>

public typealias Vector2<R: Ring> = ColVector<_2, R>
public typealias Vector3<R: Ring> = ColVector<_3, R>
public typealias Vector4<R: Ring> = ColVector<_4, R>

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>
public typealias DRowVector<R: Ring> = RowVector<DynamicSize, R>
public typealias DColVector<R: Ring> = ColVector<DynamicSize, R>
public typealias DVector<R: Ring>    = DColVector<R>

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)

public struct MatrixInterface<Impl: MatrixImpl, n: SizeType, m: SizeType, R>: SetType where Impl.BaseRing == R {
    public typealias BaseRing = R
    public typealias Impl = DefaultMatrixImpl<R>
    public typealias Initializer = Impl.Initializer
    
    internal var impl: Impl
    
    public init(impl: Impl) {
        assert(n.isDynamic || n.intValue == impl.size.rows)
        assert(m.isDynamic || m.intValue == impl.size.cols)
        self.impl = impl
    }
    
    public subscript(i: Int, j: Int) -> R {
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
    
    public var transposed: MatrixInterface<Impl, m, n, R> {
        .init(impl: impl.transposed)
    }
    
    public func rowVector(_ i: Int) -> MatrixInterface<Impl, _1, m, R> {
        submatrix(rowRange: i ..< i + 1, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, _1, m, R>.self)
    }
    
    public func colVector(_ j: Int) -> MatrixInterface<Impl, n, _1, R> {
        submatrix(rowRange: 0 ..< size.rows, colRange: j ..< j + 1)
            .as(MatrixInterface<Impl, n, _1, R>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, m, R> {
        submatrix(rowRange: rowRange, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, DynamicSize, m, R>.self)
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> MatrixInterface<Impl, n, DynamicSize, R> {
        submatrix(rowRange: 0 ..< size.rows, colRange: colRange)
            .as(MatrixInterface<Impl, n, DynamicSize, R>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, DynamicSize, R> {
        .init(impl: impl.submatrix(rowRange: rowRange, colRange: colRange))
    }
    
    public func serialize() -> [R] {
        impl.serialize()
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.impl == b.impl
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(impl: a.impl + b.impl)
    }
    
    public prefix static func -(a: Self) -> Self {
        .init(impl: -a.impl)
    }
    
    public static func -(a: Self, b: Self) -> Self {
        .init(impl: a.impl - b.impl)
    }
    
    public static func *(r: R, a: Self) -> Self {
        .init(impl: r * a.impl)
    }
    
    public static func *(a: Self, r: R) -> Self {
        .init(impl: a.impl * r)
    }
    
    public static func * <p>(a: MatrixInterface<Impl, n, m, R>, b: MatrixInterface<Impl, m, p, R>) -> MatrixInterface<Impl, n, p, R> {
        .init(impl: a.impl * b.impl)
    }
    
    public func `as`<n1, m1>(_ type: MatrixInterface<Impl, n1, m1, R>.Type) -> MatrixInterface<Impl, n1, m1, R> {
        MatrixInterface<Impl, n1, m1, R>(impl: impl)
    }
    
    public var asDynamicMatrix: MatrixInterface<Impl, DynamicSize, DynamicSize, R> {
        self.as(MatrixInterface<Impl, DynamicSize, DynamicSize, R>.self)
    }
    
    public var description: String {
        impl.description
    }
    
    public var detailDescription: String {
        impl.detailDescription
    }
    
    public static var symbol: String {
        if !m.isDynamic && m.intValue == 1 {
            if !n.isDynamic {
                return "Vec<\(n.intValue); \(R.symbol)>"
            } else {
                return "Vec<\(R.symbol)>"
            }
        }
        if !n.isDynamic && n.intValue == 1 {
            if !m.isDynamic {
                return "rVec<\(m.intValue); \(R.symbol)>"
            } else {
                return "rVec<\(R.symbol)>"
            }
        }
        if !n.isDynamic && !m.isDynamic {
            return "Mat<\(n.intValue), \(m.intValue); \(R.symbol)>"
        } else {
            return "Mat<\(R.symbol)>"
        }
    }
}

extension MatrixInterface where n == m { // n, m: possibly dynamic
    public var isInvertible: Bool {
        isSquare && impl.isInvertible
    }
    
    public var inverse: Self? {
        isSquare ? impl.inverse.flatMap{ .init(impl: $0) } : nil
    }
    
    public var determinant: R {
        impl.determinant
    }

    public var trace: R {
        impl.trace
    }
}

// ColVector
extension MatrixInterface where m == _1 { // n: possibly dynamic
    public subscript(index: Int) -> R {
        get {
            self[index, 0]
        } set {
            self[index, 0] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> R {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
}

// RowVector
extension MatrixInterface where n == _1 { // m: possibly dynamic
    public subscript(index: Int) -> R {
        get {
            self[0, index]
        } set {
            self[0, index] = newValue
        }
    }
    
    public static func •(_ left: Self, _ right: Self) -> R {
        assert(left.size == right.size)
        return (0 ..< left.size.rows).sum { i in left[i] * right[i] }
    }
}

//extension Matrix: Codable where R: Codable {
//    enum CodingKeys: String, CodingKey {
//        case rows, cols, grid
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        let rows = try c.decode(Int.self, forKey: .rows)
//        let cols = try c.decode(Int.self, forKey: .cols)
//        let grid = try c.decode([R].self, forKey: .grid)
//        self.init(size: (rows, cols), grid: grid)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var c = encoder.container(keyedBy: CodingKeys.self)
//        try c.encode(size.rows, forKey: .rows)
//        try c.encode(size.cols, forKey: .cols)
//        try c.encode(asArray, forKey: .grid)
//    }
//}

// DefaultImpl specific
extension MatrixInterface where Impl == DefaultMatrixImpl<R> {
    public var nonZeroComponents: AnySequence<MatrixComponent<R>> {
        impl.nonZeroComponents
    }

    public func mapNonZeroComponents(_ f: (Int, Int, R) -> R) -> Self {
        .init(impl: impl.mapNonZeroComponents(f))
    }

//    public func splitHorizontally(at j0: Int) -> (Matrix<n, DynamicSize, R>, Matrix<n, DynamicSize, R>) {
//        let (Ac, Bc) = nonZeroComponents.split { $0.col < j0 }
//        let A = Matrix<n, DynamicSize, R>(size: (size.rows, j0)) { setEntry in
//            Ac.forEach { (i, j, a) in setEntry(i, j, a) }
//        }
//        let B = Matrix<n, DynamicSize, R>(size: (size.rows, size.cols - j0)) { setEntry in
//            Bc.forEach { (i, j, a) in setEntry(i, j - j0, a) }
//        }
//        return (A, B)
//    }
//
//    public func splitVertically(at i0: Int) -> (Matrix<DynamicSize, m, R>, Matrix<DynamicSize, m, R>) {
//        let (Ac, Bc) = nonZeroComponents.split { $0.row < i0 }
//        let A = Matrix<DynamicSize, m, R>(size: (i0, size.cols)) { setEntry in
//            Ac.forEach { (i, j, a) in setEntry(i, j, a) }
//        }
//        let B = Matrix<DynamicSize, m, R>(size: (size.rows - i0, size.cols)) { setEntry in
//            Bc.forEach { (i, j, a) in setEntry(i - i0, j, a) }
//        }
//        return (A, B)
//    }
//
//    public func permuteRows(by σ: Permutation<n>) -> Self {
//        .init(size: size) { setEntry in
//            nonZeroComponents.forEach{ (i, j, a) in
//                setEntry(σ[i], j, a)
//            }
//        }
//    }
//
//    public func permuteCols(by σ: Permutation<m>) -> Self {
//        .init(size: size) { setEntry in
//            nonZeroComponents.forEach{ (i, j, a) in
//                setEntry(i, σ[j], a)
//            }
//        }
//    }
//
//    public func concatVertically<n1>(_ B: Matrix<n1, m, R>) -> Matrix<DynamicSize, m, R> {
//        let A = self
//        assert(A.size.cols == B.size.cols)
//
//        return .init(size: (A.size.rows + B.size.rows, A.size.cols)) { setEntry in
//            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
//            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i + A.size.rows, j, a) }
//        }
//    }
//
//    public func concatHorizontally<m1>(_ B: Matrix<n, m1, R>) -> Matrix<n, DynamicSize, R> {
//        let A = self
//        assert(A.size.rows == B.size.rows)
//
//        return .init(size: (A.size.rows, A.size.cols + B.size.cols)) { setEntry in
//            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
//            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j + A.size.cols, a) }
//        }
//    }
//
//    public static func ⊕ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
//        .init(size: (A.size.rows + B.size.rows, A.size.cols + B.size.cols)) { setEntry in
//            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
//            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i + A.size.rows, j + A.size.cols, a) }
//        }
//    }
//
//    public static func ⊗ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
//        .init(size: (A.size.rows * B.size.rows, A.size.cols * B.size.cols)) { setEntry in
//            A.nonZeroComponents.forEach { (i, j, a) in
//                B.nonZeroComponents.forEach { (k, l, b) in
//                    let p = i * B.size.rows + k
//                    let q = j * B.size.cols + l
//                    let c = a * b
//                    setEntry(p, q, c)
//                }
//            }
//        }
//    }
}

//
