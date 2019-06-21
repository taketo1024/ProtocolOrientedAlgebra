import Foundation

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)

public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>
public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public struct Matrix<n: SizeType, m: SizeType, R: Ring>: SetType {
    public typealias CoeffRing = R
    
    internal var impl: MatrixImpl<R>
    internal init(_ impl: MatrixImpl<R>) {
        self.impl = impl
    }
    
    public var rows: Int { return impl.rows }
    public var cols: Int { return impl.cols }
    
    private mutating func willMutate() {
        if !isKnownUniquelyReferenced(&impl) {
            impl = impl.copy()
        }
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            return impl[i, j]
        } set {
            willMutate()
            impl[i, j] = newValue
        }
    }
    
    public var isZero: Bool {
        return impl.isZero
    }
    
    public var isIdentity: Bool {
        return impl.isIdentity
    }
    
    public var isDiagonal: Bool {
        return impl.isDiagonal
    }
    
    public var diagonal: [R] {
        return (0 ..< Swift.min(rows, cols)).map{ i in self[i, i] }
    }
    
    public var transposed: Matrix<m, n, R> {
        return Matrix<m, n, R>(impl.copy().transpose())
    }
    
    public func rowVector(_ i: Int) -> RowVector<m, R> {
        return RowVector(impl.submatrix(i ..< i + 1, 0 ..< cols))
    }
    
    public func colVector(_ j: Int) -> ColVector<n, R> {
        return ColVector(impl.submatrix(0 ..< rows, j ..< j + 1))
    }
    
    public var grid: [R] {
        return impl.grid
    }
    
    public var nonZeroComponents: [MatrixComponent<R>] {
        return impl.components
    }
    
    public func mapNonZeroComponents<R2>(_ f: (R) -> R2) -> Matrix<n, m, R2> {
        return Matrix<n, m, R2>(impl.mapComponents(f))
    }
    
    func submatrix(rowRange: CountableRange<Int>) -> Matrix<DynamicSize, m, R> {
        return .init(impl.submatrix(rowRange: rowRange) )
    }
    
    func submatrix(colRange: CountableRange<Int>) -> Matrix<n, DynamicSize, R> {
        return .init(impl.submatrix(colRange: colRange) )
    }
    
    func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> DMatrix<R> {
        return .init(impl.submatrix(rowRange, colRange))
    }
    
    func concatHorizontally<m1>(_ B: Matrix<n, m1, R>) -> Matrix<n, DynamicSize, R> {
        assert(rows == B.rows)
        return .init(impl.concatHorizontally(B.impl))
    }
    
    func concatVertically<n1>(_ B: Matrix<n1, m, R>) -> Matrix<n1, m, R> {
        assert(cols == B.cols)
        return .init(impl.concatVertically(B.impl))
    }
    
    func concatDiagonally<n1, m1>(_ B: Matrix<n1, m1, R>) -> DMatrix<R> {
        return .init(impl.concatDiagonally(B.impl))
    }
    
    func blocks(rowSizes: [Int], colSizes: [Int]) -> [[DMatrix<R>]] {
        var i = 0
        return rowSizes.map { r -> [DMatrix<R>] in
            defer { i += r }
            
            var j = 0
            return colSizes.map { c -> DMatrix<R> in
                defer { j += c }
                return self.submatrix(rowRange: i ..< i + r, colRange: j ..< j + c)
            }
        }
    }

    public func `as`<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        assert(n.isDynamic || n.intValue == rows)
        assert(m.isDynamic || m.intValue == cols)
        
        return Matrix<n, m, R>(impl)
    }
    
    public static func ==(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Bool {
        return a.impl == b.impl
    }
    
    public static func +(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix(a.impl + b.impl)
    }
    
    public prefix static func -(a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix(-a.impl)
    }
    
    public static func -(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return a + (-b)
    }
    
    public static func *(r: R, a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix(r * a.impl)
    }
    
    public static func *(a: Matrix<n, m, R>, r: R) -> Matrix<n, m, R> {
        return Matrix(a.impl * r)
    }
    
    public static func * <p>(a: Matrix<n, m, R>, b: Matrix<m, p, R>) -> Matrix<n, p, R> {
        return Matrix<n, p, R>(a.impl * b.impl)
    }
    
    static func ⊕ <n1, m1>(a: Matrix<n, m, R>, b: Matrix<n1, m1, R>) -> DMatrix<R> {
        return DMatrix<R>(a.impl.concatDiagonally(b.impl))
    }
    
    static func ⊗ <n1, m1>(a: Matrix<n, m, R>, b: Matrix<n1, m1, R>) -> DMatrix<R> {
        let (n, m) = (b.rows, b.cols)
        return DMatrix<R>(rows: a.rows * b.rows, cols: a.cols * b.cols) { (i, j) in
            a[i / n, j / m] * b[i % n, j % m]
        }
    }
    
    public var description: String {
        return "[" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public var detailDescription: String {
        if (rows, cols) == (0, 0) {
            return "[]"
        } else if rows == 0 {
            return "[" + String(repeating: "\t,", count: cols - 1) + "\t]"
        } else if cols == 0 {
            return "[" + String(repeating: "\t;", count: rows - 1) + "\t]"
        } else {
            return "[\t" + (0 ..< rows).map({ i in
                return (0 ..< cols).map({ j in
                    return "\(self[i, j])"
                }).joined(separator: ",\t")
            }).joined(separator: "\n\t") + "]"
        }
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

extension Matrix: AdditiveGroup, Module where n: StaticSizeType, m: StaticSizeType {
    public init(_ grid: [R]) {
        let (rows, cols) = (n.intValue, m.intValue)
        self.init(MatrixImpl(rows: rows, cols: cols, grid: grid))
    }
    
    public init(_ grid: R...) {
        self.init(grid)
    }
    
    public init(generator g: (Int, Int) -> R) {
        let (rows, cols) = (n.intValue, m.intValue)
        self.init(MatrixImpl(rows: rows, cols: cols, generator: g))
    }
    
    public init(components: [MatrixComponent<R>]) {
        let (rows, cols) = (n.intValue, m.intValue)
        self.init(MatrixImpl(rows: rows, cols: cols, components: components))
    }
    
    // Convenience initializers
    public init(fill a: R) {
        self.init() { (_, _) in a }
    }
    
    public init(diagonal d: [R]) {
        self.init() { (i, j) in (i == j && i < d.count) ? d[i] : R.zero }
    }
    
    public init(scalar a: R) {
        self.init() { (i, j) in (i == j) ? a : R.zero }
    }
    
    public static var zero: Matrix<n, m, R> {
        return Matrix(components:[])
    }
    
    public static func unit(_ i0: Int, _ j0: Int) -> Matrix<n, m, R> {
        return Matrix { (i, j) in (i, j) == (i0, j0) ? .identity : .zero }
    }
}

extension Matrix: Monoid, Ring where n == m, n: StaticSizeType {
    public init(from n : 𝐙) {
        self.init(scalar: R(from: n))
    }
    
    public var size: Int {
        return rows
    }
    
    public static var identity: SquareMatrix<n, R> {
        return Matrix<n, n, R> { $0 == $1 ? .identity : .zero }
    }
    
    public var isInvertible: Bool {
        return determinant.isInvertible
    }
    
    public var inverse: SquareMatrix<n, R>? {
        if size >= 5 {
            print("warn: Directly computing matrix-inverse can be extremely slow. Use elimination().determinant instead.")
        }
        return impl.inverse.map{ SquareMatrix($0) }
    }
    
    public var trace: R {
        return impl.trace
    }
    
    public var determinant: R {
        if size >= 5 {
            print("warn: Directly computing determinant can be extremely slow. Use elimination().determinant instead.")
        }
        
        return impl.determinant
    }
    
    public func pow(_ n: 𝐙) -> SquareMatrix<n, R> {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        return self[0, 0]
    }
}

public extension Matrix where n == DynamicSize, m == DynamicSize {
    init(rows: Int, cols: Int, grid: [R]) {
        self.init(MatrixImpl(rows: rows, cols: cols, grid: grid))
    }
    
    init(rows: Int, cols: Int, grid: R ...) {
        self.init(rows: rows, cols: cols, grid: grid)
    }
    
    init(rows: Int, cols: Int, generator g: (Int, Int) -> R) {
        self.init(MatrixImpl(rows: rows, cols: cols, generator: g))
    }
    
    init(rows: Int, cols: Int, components: [MatrixComponent<R>]) {
        self.init(MatrixImpl(rows: rows, cols: cols, components: components))
    }
    
    init(rows: Int, cols: Int, fill a: R) {
        self.init(rows: rows, cols: cols) { (_, _) in a }
    }
    
    init(rows: Int, cols: Int, diagonal d: [R]) {
        self.init(rows: rows, cols: cols) { (i, j) in (i == j && i < d.count) ? d[i] : .zero }
    }
    
    init(size n: Int, scalar a: R) {
        self.init(rows: n, cols: n) { (i, j) in (i == j) ? a : .zero }
    }
    
    static func identity(size n: Int) -> DMatrix<R> {
        return DMatrix(size: n, scalar: .identity)
    }
    
    static func zero(size n: Int) -> DMatrix<R> {
        return DMatrix.zero(rows: n, cols: n)
    }
    
    static func zero(rows: Int, cols: Int) -> DMatrix<R> {
        return DMatrix(rows: rows, cols: cols) { (_, _) in .zero }
    }
    
    static func unit(rows: Int, cols: Int, _ coord: (Int, Int)) -> DMatrix<R> {
        return DMatrix(rows: rows, cols: cols) { (i, j) in (i, j) == coord ? .identity : .zero }
    }
    
    var inverse: DMatrix<R>? {
        assert(rows == cols)
        if rows >= 5 {
            print("warn: Directly computing matrix-inverse can be extremely slow. Use elimination().determinant instead.")
        }
        return impl.inverse.map{ DMatrix($0) }
    }
    
    var trace: R {
        assert(rows == cols)
        return impl.trace
    }
    
    var determinant: R {
        assert(rows == cols)
        if rows >= 5 {
            print("warn: Directly computing determinant can be extremely slow. Use elimination().determinant instead.")
        }
        
        return impl.determinant
    }
    
    func pow(_ n: 𝐙) -> DMatrix<R> {
        assert(rows == cols)
        assert(n >= 0)
        return (0 ..< n).reduce(.identity(size: rows)){ (res, _) in self * res }
    }
    
    mutating func transpose() {
        impl.transpose()
    }
}

public extension Matrix where R: RealSubset {
    var asReal: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(impl.mapComponents{ $0.asReal })
    }
}

public extension Matrix where R: ComplexSubset {
    var asComplex: Matrix<n, m, 𝐂> {
        return Matrix<n, m, 𝐂>(impl.mapComponents{ $0.asComplex })
    }
}

public extension Matrix where R == 𝐂 {
    var realPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(impl.mapComponents{ $0.realPart })
    }
    
    var imaginaryPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(impl.mapComponents{ $0.imaginaryPart })
    }
    
    var adjoint: Matrix<m, n, R> {
        return transposed.mapNonZeroComponents { $0.conjugate }
    }
}

extension Matrix: Codable where R: Codable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        self.impl = try c.decode(MatrixImpl<R>.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(impl)
    }
}
