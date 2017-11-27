import Foundation

public typealias ColVector<n: _Int, R: Ring>    = Matrix<n, _1, R>
public typealias RowVector<m: _Int, R: Ring>    = Matrix<_1, m, R>
public typealias SquareMatrix<n: _Int, R: Ring> = Matrix<n, n, R>
public typealias DynamicMatrix<R: Ring>         = Matrix<Dynamic, Dynamic, R>
public typealias DynamicColVector<R: Ring>      = Matrix<Dynamic, _1, R>
public typealias DynamicRowVector<R: Ring>      = Matrix<_1, Dynamic, R>

public typealias MatrixComponent<R> = (row: Int, col: Int, value: R)

public struct Matrix<n: _Int, m: _Int, R: Ring>: Module, Sequence {
    public typealias CoeffRing = R

    public let rows: Int
    public let cols: Int
    public var grid: [R]

    // Root Initializer
    private init(_ rows: Int, _ cols: Int, _ grid: [R]) {
        self.rows = rows
        self.cols = cols
        self.grid = grid
    }

    // 1. Initialize by Grid.
    public init(rows r: Int? = nil, cols c: Int? = nil, grid g: [R]) {
        let (rows, cols) = Matrix.determineSize(r, c)

        let grid = { () -> [R] in
            let (k, l) = (g.count, rows * cols)
            if  k == l {
                return g
            } else if k < l {
                return g + Array(repeating: R.zero, count: l - k)
            } else {
                return g[0 ..< l].toArray()
            }
        }()

        self.init(rows, cols, grid)
    }

    // 2. Initialize by Generator.
    public init(rows r: Int? = nil, cols c: Int? = nil, generator g: (Int, Int) -> R) {
        let (rows, cols) = Matrix.determineSize(r, c)
        let grid = (0 ..< rows * cols).map { (index: Int) -> R in
            let (i, j) = index /% cols
            return g(i, j)
        }

        self.init(rows, cols, grid)
    }

    // 3. Initialize by Components.
    public init(rows r: Int? = nil, cols c: Int? = nil, components: [MatrixComponent<R>]) {
        let (rows, cols) = Matrix.determineSize(r, c)
        var grid = Array(repeating: R.zero, count: rows * cols)
        for (i, j, a) in components {
            grid[(i * cols) + j] = a
        }

        self.init(rows, cols, grid)
    }

    // Convenience Initializer 1.
    public init(_ grid: R...) {
        self.init(rows: nil, cols: nil, grid: grid)
    }

    // Convenience Initializer 2.
    public init(rows r: Int? = nil, cols c: Int? = nil, fill: R = .zero) {
        let (rows, cols) = Matrix.determineSize(r, c)
        let grid = Array(repeating: fill, count: rows * cols)
        self.init(rows, cols, grid)
    }

    // Convenience Initializer 3.
    public init(rows r: Int? = nil, cols c: Int? = nil, diagonal: [R]) {
        let (rows, cols) = Matrix.determineSize(r, c)
        var grid = Array(repeating: R.zero, count: rows * cols)
        for (i, a) in diagonal.enumerated() {
            grid[(i * cols) + i] = a
        }
        self.init(rows, cols, grid)
    }

    @_transparent
    public func gridIndex(_ i: Int, _ j: Int) -> Int {
        return (i * cols) + j
    }

    public subscript(i: Int, j: Int) -> R {
        @_transparent
        get { return grid[gridIndex(i, j)] }

        @_transparent
        set { grid[gridIndex(i, j)] = newValue }
    }

    public func makeIterator() -> AnyIterator<(Int, Int, R)> {
        return AnySequence(grid.lazy.enumerated().map{ (index, a) in (index / cols, index % cols, a) }).makeIterator()
    }

    public static var zero: Matrix<n, m, R> {
        return Matrix<n, m, R> { _,_ in 0 }
    }

    public static func ==(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Bool {
        assert((a.rows, a.cols) == (b.rows, b.cols), "Mismatching matrix size.")
        return a.grid == b.grid
    }

    public static func +(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        assert((a.rows, a.cols) == (b.rows, b.cols), "Mismatching matrix size.")
        return Matrix(rows: a.rows, cols: a.cols) { (i, j) in a[i, j] + b[i, j] }
    }

    public prefix static func -(a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix(rows: a.rows, cols: a.cols) { (i, j) in -a[i, j] }
    }

    public static func *(r: R, a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix(rows: a.rows, cols: a.cols) { (i, j) in r * a[i, j] }
    }

    public static func *(a: Matrix<n, m, R>, r: R) -> Matrix<n, m, R> {
        return Matrix(rows: a.rows, cols: a.cols) { (i, j) in a[i, j] * r }
    }

    @_inlineable
    public static func * <p>(a: Matrix<n, m, R>, b: Matrix<m, p, R>) -> Matrix<n, p, R> {
        assert(a.cols == b.rows, "Mismatching matrix size.")
        return Matrix<n, p, R>(rows: a.rows, cols: b.cols) { (i, k) in
            (0 ..< a.cols).sum { j in a[i, j] * b[j, k] }
        }
    }

    public var transposed: Matrix<m, n, R> {
        return Matrix<m, n, R>(rows: cols, cols: rows) { (i, j) in self[j, i] }
    }

    // --TODO delete
    public func rowArray(_ i: Int) -> [R] {
        return (0 ..< cols).map{ j in self[i, j] }
    }

    public func colArray(_ j: Int) -> [R] {
        return (0 ..< rows).map{ i in self[i, j] }
    }
    // --TODO

    public func rowVector(_ i: Int) -> RowVector<m, R> {
        return submatrix(rowRange: i ..< i + 1)
    }

    public func colVector(_ j: Int) -> ColVector<n, R> {
        return submatrix(colRange: j ..< j + 1)
    }

    public func submatrix<k: _Int>(rowRange: CountableRange<Int>) -> Matrix<k, m, R> {
        return submatrix(rowRange, 0 ..< cols)
    }

    public func submatrix<k: _Int>(colRange: CountableRange<Int>) -> Matrix<n, k, R> {
        return submatrix(0 ..< rows, colRange)
    }

    public func submatrix<k: _Int, l: _Int>(_ rowRange: CountableRange<Int>, _ colRange: CountableRange<Int>) -> Matrix<k, l, R> {
        let (r, c) = (rowRange, colRange)
        return Matrix<k, l, R>(rows: r.upperBound - r.lowerBound, cols: c.upperBound - c.lowerBound) { (i, j) in
            self[i + r.lowerBound, j + c.lowerBound]
        }
    }

    public var asDynamic: DynamicMatrix<R> {
        if let A = self as? DynamicMatrix<R> {
            return A
        } else {
            return DynamicMatrix<R>(rows: rows, cols: cols, grid: grid)
        }
    }

    public var hashValue: Int {
        return 0 // TODO
    }

    public var description: String {
        return "[" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }

    public var detailDescription: String {
        return "[\t" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ",\t")
        }).joined(separator: "\n\t") + "]"
    }

    public static var symbol: String {
        return "M(\((n.self == Dynamic.self ? "?" : "\(n.intValue)")), \((m.self == Dynamic.self ? "?" : "\(m.intValue)")); \(R.symbol))"
    }

    private static func determineSize(_ rows: Int?, _ cols: Int?) -> (rows: Int, cols: Int) {
        // true: determined, false: not determined
        switch (!(n.self is Dynamic.Type), !(m.self is Dynamic.Type), rows != nil, cols != nil) {
        case (true, true, _, _):
            assert(rows == nil || rows! == n.intValue, "rows mismatch with type-parameter")
            assert(cols == nil || cols! == m.intValue, "cols mismatch with type-parameter")
            return (n.intValue, m.intValue)
        case (false, false, true, true):
            return (rows!, cols!)
        case (true, false, _, true):
            assert(rows == nil || rows! == n.intValue, "rows mismatch with type-parameter")
            return (n.intValue, cols!)
        case (false, true, true, _):
            assert(cols == nil || cols! == m.intValue, "cols mismatch with type-parameter")
            return (rows!, m.intValue)
        default:
            fatalError("Matrix size indeterminable.")
        }
    }
}

public extension Matrix where R: EuclideanRing {
    // MEMO use computational Matrix for more direct manipulation.
    public func eliminate(form: MatrixForm = .Diagonal, debug: Bool = false) -> MatrixEliminationResultWrapper<n, m, R> {
        let cmatrix = ComputationalMatrix(self)
        let eliminator = { () -> MatrixEliminator<R> in
            switch form {
            case .RowEchelon: return RowEchelonEliminator(cmatrix, debug: debug)
            case .ColEchelon: return ColEchelonEliminator(cmatrix, debug: debug)
            case .RowHermite: return RowHermiteEliminator(cmatrix, debug: debug)
            case .ColHermite: return ColHermiteEliminator(cmatrix, debug: debug)
            case .Diagonal:   return DiagonalEliminator  (cmatrix, debug: debug)
            case .Smith:      return SmithEliminator     (cmatrix, debug: debug)
            default: fatalError()
            }
        }()

        let result = eliminator.run()
        return MatrixEliminationResultWrapper(self, result)
    }
}

public extension Matrix where m == _1 {
    public subscript(index: Int) -> R {
        @_transparent
        get { return self[index, 0] }

        @_transparent
        set { self[index, 0] = newValue }
    }
}

public extension Matrix where n == _1 {
    public subscript(index: Int) -> R {
        @_transparent
        get { return self[0, index] }

        @_transparent
        set { self[0, index] = newValue }
    }
}

// TODO: conform to Ring after conditional conformance is supported.
public extension Matrix where n == m {
    public static var identity: Matrix<n, n, R> {
        assert(n.self != Dynamic.self)
        return identity(size: n.intValue)
    }

    public static func identity(size: Int) -> Matrix<n, n, R> {
        return Matrix<n, n, R> (rows: size, cols: size) { $0 == $1 ? 1 : 0 }
    }

    public static func ** (a: Matrix<n, n, R>, k: Int) -> Matrix<n, n, R> {
        return k == 0 ? Matrix.identity(size: a.rows) : a * (a ** (k - 1))
    }
}

public extension Matrix where n == m, R: EuclideanRing {
    public var determinant: R {
        return eliminate().determinant
    }

    public var isInvertible: Bool {
        return determinant.isInvertible
    }

    public var inverse: Matrix<n, n, R>? {
        return eliminate().inverse
    }
}
