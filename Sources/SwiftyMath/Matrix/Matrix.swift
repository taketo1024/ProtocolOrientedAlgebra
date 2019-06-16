import Foundation

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)

public enum MatrixForm {
    case Default
    case RowEchelon
    case ColEchelon
    case RowHermite
    case ColHermite
    case Diagonal
    case Smith
}

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public struct Matrix<n: SizeType, m: SizeType, R: Ring>: SetType {
    public typealias CoeffRing = R
    
    internal var impl: MatrixImpl<R>
    internal var elimCache: Cache<[MatrixForm: AnyObject]> = Cache([:])
    
    internal init(_ impl: MatrixImpl<R>) {
        self.impl = impl
    }
    
    public var rows: Int { return impl.rows }
    public var cols: Int { return impl.cols }
    
    private mutating func willMutate() {
        if !isKnownUniquelyReferenced(&impl) {
            impl = impl.copy()
        }
        elimCache = Cache([:])
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            return impl[i, j]
        } set {
            willMutate()
            impl[i, j] = newValue
        }
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
    
    public var isZero: Bool {
        return impl.isZero
    }
    
    public var isIdentity: Bool {
        return impl.isIdentity
    }
    
    public var diagonal: [R] {
        return (0 ..< Swift.min(rows, cols)).map{ i in self[i, i] }
    }
    
    public var transposed: Matrix<m, n, R> {
        return Matrix<m, n, R>(impl.transposed)
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
    
    public func nonZeroComponents(ofRow i: Int) -> [MatrixComponent<R>] {
        return impl.components(ofRow: i)
    }
    
    public func nonZeroComponents(ofCol j: Int) -> [MatrixComponent<R>] {
        return impl.components(ofCol: j)
    }
    
    public func mapNonZeroComponents<R2>(_ f: (R) -> R2) -> Matrix<n, m, R2> {
        return Matrix<n, m, R2>(impl.mapComponents(f))
    }
    
    public var hashValue: Int {
        return impl.hashValue
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

extension Matrix: Sequence {
    // TODO directly iterate impl
    public func makeIterator() -> IndexingIterator<[(Int, Int, R)]> {
        return nonZeroComponents.map{ c in (c.row, c.col, c.value) }.makeIterator()
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
    
    static func ⊕ (a: DMatrix<R>, b: DMatrix<R>) -> DMatrix<R> {
        return DMatrix<R>(a.impl ⊕ b.impl)
    }
    
    static func ⊗ (a: DMatrix<R>, b: DMatrix<R>) -> DMatrix<R> {
        let (n, m) = (b.rows, b.cols)
        return DMatrix<R>(rows: a.rows * b.rows, cols: a.cols * b.cols) { (i, j) in
            a[i / n, j / m] * b[i % n, j % m]
        }
    }
    
    func submatrix(rowRange: CountableRange<Int>) -> DMatrix<R> {
        return Matrix<DynamicSize, m, R>(impl.submatrix(rowRange: rowRange) )
    }
    
    func submatrix(colRange: CountableRange<Int>) -> DMatrix<R> {
        return Matrix<n, DynamicSize, R>(impl.submatrix(colRange: colRange) )
    }
    
    func submatrix(rowRange: CountableRange<Int>, colRange: CountableRange<Int>) -> DMatrix<R> {
        return DMatrix(impl.submatrix(rowRange, colRange))
    }
    
    func submatrix(rowsMatching r: (Int) -> Bool, colsMatching c: (Int) -> Bool) -> DMatrix<R> {
        return DMatrix(impl.submatrix(r, c))
    }
    
    func concatRows(with A: DMatrix<R>) -> Matrix<DynamicSize, m, R> {
        return DMatrix<R>(impl.concatRows(A.impl))
    }
    
    func concatCols(with A: DMatrix<R>) -> Matrix<n, DynamicSize, R> {
        return DMatrix<R>(impl.concatCols(A.impl))
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
}

extension Matrix: VectorSpace, FiniteDimVectorSpace where R: Field, n: StaticSizeType, m: StaticSizeType {
    public static var dim: Int {
        return n.intValue * m.intValue
    }
    
    public static var standardBasis: [Matrix<n, m, R>] {
        return (0 ..< n.intValue).flatMap { i -> [Matrix<n, m, R>] in
            (0 ..< m.intValue).map { j -> Matrix<n, m, R> in
                Matrix.unit(i, j)
            }
        }
    }
    
    public var standardCoordinates: [R] {
        return grid
    }
}

public extension Matrix where R: EuclideanRing {
    typealias EliminationResult = MatrixEliminationResult<n, m, R>
    
    @discardableResult
    mutating func eliminate(form: MatrixForm = .Diagonal) -> EliminationResult {
        let e = impl.eliminate(form: form)
        return EliminationResult(self, e)
    }
    
    func elimination(form: MatrixForm = .Diagonal) -> EliminationResult {
        if let res = elimCache.value?[form] as? EliminationResult {
            return res
        }
        
        let e = impl.copy().eliminate(form: form)
        let res = EliminationResult(self, e)
        elimCache.value![form] = (res as AnyObject)
        
        return res
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
        return Matrix<m, n, R>(impl.transposed.mapComponents{ $0.conjugate })
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
