//
//  MatrixInterafce.swift
//
//
//  Created by Taketo Sano.
//

public struct MatrixInterface<Impl: MatrixImpl, n: SizeType, m: SizeType>: SetType {
    public typealias BaseRing = Impl.BaseRing
    public typealias Initializer = Impl.Initializer
    
    public var impl: Impl
    
    public init(_ impl: Impl) {
        assert(n.isDynamic || n.intValue == impl.size.rows)
        assert(m.isDynamic || m.intValue == impl.size.cols)
        self.impl = impl
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
    
    public var transposed: MatrixInterface<Impl, m, n> {
        .init(impl.transposed)
    }
    
    public func rowVector(_ i: Int) -> MatrixInterface<Impl, _1, m> {
        submatrix(rowRange: i ..< i + 1, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, _1, m>.self)
    }
    
    public func colVector(_ j: Int) -> MatrixInterface<Impl, n, _1> {
        submatrix(rowRange: 0 ..< size.rows, colRange: j ..< j + 1)
            .as(MatrixInterface<Impl, n, _1>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, m> {
        submatrix(rowRange: rowRange, colRange: 0 ..< size.cols)
            .as(MatrixInterface<Impl, DynamicSize, m>.self)
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> MatrixInterface<Impl, n, DynamicSize> {
        submatrix(rowRange: 0 ..< size.rows, colRange: colRange)
            .as(MatrixInterface<Impl, n, DynamicSize>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixInterface<Impl, DynamicSize, DynamicSize> {
        .init(impl.submatrix(rowRange: rowRange, colRange: colRange))
    }
    
    public var nonZeroComponents: AnySequence<MatrixComponent<BaseRing>> {
        impl.nonZeroComponents
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
    
    public static func * <p>(a: MatrixInterface<Impl, n, m>, b: MatrixInterface<Impl, m, p>) -> MatrixInterface<Impl, n, p> {
        .init(a.impl * b.impl)
    }
    
    public func `as`<n1, m1>(_ type: MatrixInterface<Impl, n1, m1>.Type) -> MatrixInterface<Impl, n1, m1> {
        MatrixInterface<Impl, n1, m1>(impl)
    }
    
    public var asDynamicMatrix: MatrixInterface<Impl, DynamicSize, DynamicSize> {
        self.as(MatrixInterface<Impl, DynamicSize, DynamicSize>.self)
    }
    
    public var description: String {
        impl.description
    }
    
    public var detailDescription: String {
        impl.detailDescription
    }
    
    public static var symbol: String {
        func str(_ t: SizeType.Type) -> String {
            !t.isDynamic ? "\(t.intValue)" : "d"
        }
        if !m.isDynamic && m.intValue == 1 {
            return "ColVec<\(str(n.self)); \(BaseRing.symbol)>"
        }
        if !n.isDynamic && n.intValue == 1 {
            return "RowVec<\(str(n.self)); \(BaseRing.symbol)>"
        }
        return "Mat<\(str(n.self)), \(str(n.self)); \(BaseRing.symbol)>"
    }
}

extension MatrixInterface where n == m { // n, m: possibly dynamic
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

// ColVector
extension MatrixInterface where m == _1 { // n: possibly dynamic
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
}

// RowVector
extension MatrixInterface where n == _1 { // m: possibly dynamic
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

