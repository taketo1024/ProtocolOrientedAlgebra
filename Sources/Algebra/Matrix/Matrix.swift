import Foundation

public typealias MatrixComponent<R> = (row: Int, col: Int, value: R)

public struct Matrix<n: _Int, m: _Int, R: Ring>: Module, Sequence {
    public typealias CoeffRing = R

    public let rows: Int
    public let cols: Int
    public var grid: [R]

    // 1. Initialize by Grid.
    public init(grid: [R]) {
        let (rows, cols) = (n.intValue, m.intValue)

        self.rows = rows
        self.cols = cols

        self.grid = { () -> [R] in
            let (k, l) = (grid.count, rows * cols)
            if  k == l {
                return grid
            } else if k < l {
                return grid + Array(repeating: R.zero, count: l - k)
            } else {
                return grid[0 ..< l].toArray()
            }
        }()
    }

    public init(_ grid: R...) {
        self.init(grid: grid)
    }

    // 2. Initialize by Generator.
    public init(generator g: (Int, Int) -> R) {
        let (rows, cols) = (n.intValue, m.intValue)
        let grid = (0 ..< rows * cols).map { (index: Int) -> R in
            let (i, j) = index /% cols
            return g(i, j)
        }
        self.init(grid: grid)
    }

    // 3. Initialize by Components.
    public init(components: [MatrixComponent<R>]) {
        let (rows, cols) = (n.intValue, m.intValue)
        var grid = Array(repeating: R.zero, count: rows * cols)
        for (i, j, a) in components {
            grid[(i * cols) + j] = a
        }
        self.init(grid: grid)
    }

    // Convenience Initializer 1.
    public init(fill a: R) {
        self.init() { (_, _) in a }
    }

    // Convenience Initializer 2.
    public init(diagonal d: [R]) {
        self.init() { (i, j) in (i == j && i < d.count) ? d[i] : .zero }
    }

    // Convenience Initializer 3.
    public init(scalar a: R) {
        self.init() { (i, j) in (i == j) ? a : .zero }
    }

    // Block Matrix [A, B; C, D]
    public init<n1, n2, m1, m2>(_ A: Matrix<n1, m1, R>, _ B: Matrix<n1, m2, R>, _ C: Matrix<n2, m1, R>, _ D: Matrix<n2, m2, R>) {
        let (n1, n2, m1, m2) = (n1.intValue, n2.intValue, m1.intValue, m2.intValue)
        assert(n1 + n2 == n.intValue)
        assert(m1 + m2 == m.intValue)
        self.init() { (i, j) in
            switch (i, j) {
            case (i, j) where i <  n1 && j <  m1: return A[i, j]
            case (i, j) where i >= n1 && j <  m1: return B[i - n1, j]
            case (i, j) where i <  n1 && j >= m1: return C[i, j - m1]
            case (i, j) where i >= n1 && j >= m1: return D[i - n1, j - m1]
            default: return .zero
            }
        }
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
        return Matrix { (i, j) in a[i, j] + b[i, j] }
    }

    public prefix static func -(a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix { (i, j) in -a[i, j] }
    }

    public static func *(r: R, a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return Matrix { (i, j) in r * a[i, j] }
    }

    public static func *(a: Matrix<n, m, R>, r: R) -> Matrix<n, m, R> {
        return Matrix { (i, j) in a[i, j] * r }
    }

    @_inlineable
    public static func * <p>(a: Matrix<n, m, R>, b: Matrix<m, p, R>) -> Matrix<n, p, R> {
        return Matrix<n, p, R> { (i, k) in
            (0 ..< a.cols).sum { j in a[i, j] * b[j, k] }
        }
    }

    public var transposed: Matrix<m, n, R> {
        return Matrix<m, n, R> { (i, j) in self[j, i] }
    }

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
        return Matrix<k, l, R> { (i, j) in
            self[i + rowRange.lowerBound, j + colRange.lowerBound]
        }
    }

    public var components: [MatrixComponent<R>] {
        return self.filter{ (_, _, a) in a != .zero }
    }

    public var asComputational: ComputationalMatrix<R> {
        return ComputationalMatrix(rows: rows, cols: cols, components: components)
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
        return "M(\(n.intValue), \(m.intValue)); \(R.symbol))"
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

// TODO conditional conformance
public extension Matrix where R: NormedSpace {
    public var norm: 𝐑 {
        return sqrt( self.sum { (_, _, a) in a.norm ** 2 } )
    }

    public var maxNorm: 𝐑 {
        return self.reduce(.zero) { (res, e) in Swift.max(res, e.2.norm) }
    }
}

public extension Matrix where R == 𝐑 {
    public var asComplex: Matrix<n, m, 𝐂> {
        return Matrix<n, m, 𝐂>(grid: grid.map{ 𝐂($0) })
    }
}

public extension Matrix where R == 𝐂 {
    public var realPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(grid: grid.map{ $0.real })
    }

    public var imaginaryPart: Matrix<n, m, 𝐑> {
        return Matrix<n, m, 𝐑>(grid: grid.map{ $0.imaginary })
    }

    public var adjoint: Matrix<m, n, R> {
        return Matrix<m, n, R> { (i, j) in self[j, i].conjugate }
    }
}
