import Foundation

public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>
public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public struct MatrixCoord: Hashable, Comparable, Codable, CustomStringConvertible {
    public let row, col: Int
    public init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    public func shift(_ i: Int, _ j: Int) -> MatrixCoord {
        return MatrixCoord(row + i, col + j)
    }
    
    public var transposed: MatrixCoord {
        return MatrixCoord(col, row)
    }
    
    public static func < (lhs: MatrixCoord, rhs: MatrixCoord) -> Bool {
        return (lhs.row < rhs.row) || (lhs.row == rhs.row && lhs.col < rhs.col)
    }
    
    public var description: String {
        return "(\(row), \(col))"
    }
}

public struct Matrix<n: SizeType, m: SizeType, R: Ring>: SetType, Sequence {
    public typealias CoeffRing = R
    public typealias MatrixData = [MatrixCoord : R]
    
    public var size: (rows: Int, cols: Int)
    internal var data: MatrixData
    
    public init(size: (Int, Int), data: MatrixData) {
        assert(n.isDynamic || n.intValue == size.0)
        assert(m.isDynamic || m.intValue == size.1)
        assert(data.keys.allSatisfy{ c in (0 ..< size.0).contains(c.row) && (0 ..< size.1).contains(c.col)})
        
        self.size = size
        self.data = data.filter{ (_, a) in a != .zero }
    }
    
    // MEMO: do not use for a large matrix.
    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == R {
        let cols = size.1
        let data = Dictionary(pairs: grid.enumerated().map{ (k, a) -> (MatrixCoord, R) in
            let (i, j) = (k / cols, k % cols)
            return (MatrixCoord(i, j), a)
        })
        self.init(size: size, data: data)
    }
    
    // MEMO: do not use for a large matrix.
    public init(size: (Int, Int), generator g: (Int, Int) -> R) {
        let (rows, cols) = size
        let grid = (0 ..< rows * cols).map{ k -> R in
            let (i, j) = (k / cols, k % cols)
            return g(i, j)
        }
        self.init(size: size, grid: grid)
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            return data[MatrixCoord(i, j)] ?? .zero
        } set {
            data[MatrixCoord(i, j)] = newValue
        }
    }
    
    public var isZero: Bool {
        return data.allSatisfy{ (_, a) in a == .zero }
    }
    
    public var isIdentity: Bool {
        return data.allSatisfy{ (c, a) in (c.row == c.col && a == .identity) || (c.row != c.col && a == .zero) }
    }
    
    public var isDiagonal: Bool {
        return data.allSatisfy{ (c, a) in (c.row == c.col) || (a == .zero) }
    }
    
    public var isSquare: Bool {
        return size.rows == size.cols
    }
    
    public var diagonal: [R] {
        return (0 ..< Swift.min(size.rows, size.cols)).map{ i in self[i, i] }
    }
    
    public var transposed: Matrix<m, n, R> {
        return Matrix<m, n, R>(size: (size.cols, size.rows), data: data.mapKeys{$0.transposed} )
    }
    
    fileprivate var _trace: R {
        assert(isSquare)
        return diagonal.sumAll()
    }
    
    fileprivate var _determinant: R {
        assert(isSquare)
        if size.rows >= 5 {
            print("warn: Directly computing determinant can be extremely slow. Use eliminate().determinant instead.")
        }
        
        if size.rows == 0 {
            return .identity
        }
        
        return rowVector(0).sum{ (_, j, a) in a * _cofactor(0, j) }
    }
    
    fileprivate func _cofactor(_ i: Int, _ j: Int) -> R {
        assert(isSquare)
        
        let ε = (-R.identity).pow(i + j)
        let data = self.data
            .exclude { (c, _) in c.row == i || c.col == j }
            .mapKeys{ c in
                MatrixCoord(c.row < i ? c.row : c.row - 1,
                            c.col < j ? c.col : c.col - 1)
            }
        let A = DMatrix(size: (size.rows - 1, size.cols - 1), data: data)
        return ε * A._determinant
    }
    
    fileprivate var _inverse: Matrix<n, m, R>? {
        assert(isSquare)
        if size.rows >= 5 {
            print("warn: Directly computing matrix-inverse can be extremely slow. Use eliminate().inverse instead.")
        }
        
        if let dInv = _determinant.inverse {
            return dInv * Matrix(size: size) { (i, j) in _cofactor(j, i) }
        } else {
            return nil
        }
    }
    
    public func colVector(_ j: Int) -> ColVector<n, R> {
        return ColVector(size: (size.rows, 1), data: subData(rowRange: 0 ..< size.rows, colRange: j ..< j + 1))
    }
    
    public func rowVector(_ i: Int) -> RowVector<m, R> {
        return RowVector(size: (1, size.cols), data: subData(rowRange: i ..< i + 1, colRange: 0 ..< size.cols))
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> Matrix<DynamicSize, m, R> {
        return .init(size: (rowRange.upperBound - rowRange.lowerBound, size.cols), data: subData(rowRange: rowRange, colRange: 0 ..< size.cols))
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> Matrix<n, DynamicSize, R> {
        return .init(size: (size.rows, colRange.upperBound - colRange.lowerBound), data: subData(rowRange: 0 ..< size.rows, colRange: colRange))
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> DMatrix<R> {
        return .init(size: (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound), data: subData(rowRange: rowRange, colRange: colRange))
    }
    
    private func subData(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixData {
        return data.filter{ (c, _) in
            rowRange.contains(c.row) && colRange.contains(c.col)
        }.mapKeys{ c in
            MatrixCoord(c.row - rowRange.lowerBound, c.col - colRange.lowerBound)
        }
    }
    
    public func mapNonZeroComponents<R2>(_ f: (R) -> R2) -> Matrix<n, m, R2> {
        return .init(size: size, data: data.mapValues(f))
    }
    
    public func `as`<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        return Matrix<n, m, R>(size: size, data: data)
    }
    
    public var asDynamicMatrix: DMatrix<R> {
        return self.as(DMatrix<R>.self)
    }
    
    internal var grid: [R] {
        return (0 ..< size.rows * size.cols).map { k in
            let (i, j) = (k / size.cols, k % size.cols)
            return self[i, j]
        }
    }
    
    fileprivate static func _identity(size: Int) -> Matrix<n, m, R> {
        let data = (0 ..< size).map{ i in (MatrixCoord(i, i), R.identity) }
        return Matrix(size: (size, size), data: Dictionary(pairs: data))
    }
    
    fileprivate static func _zero(size: (Int, Int)) -> Matrix<n, m, R> {
        return Matrix(size: size, data: [:])
    }
    
    fileprivate static func _unit(size: (Int, Int), coord: (Int, Int)) -> Matrix<n, m, R> {
        return Matrix(size: size, data: [MatrixCoord(coord.0, coord.1): .identity])
    }
    
    public static func ==(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Bool {
        return a.data.exclude{ $0.value == .zero } == b.data.exclude{ $0.value == .zero }
    }
    
    public static func +(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        assert(a.size == b.size)
        return Matrix(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +))
    }
    
    public prefix static func -(a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return a.mapNonZeroComponents(-)
    }
    
    public static func -(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        assert(a.size == b.size)
        return Matrix(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: -))
    }
    
    public static func *(r: R, a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        return a.mapNonZeroComponents{ r * $0 }
    }
    
    public static func *(a: Matrix<n, m, R>, r: R) -> Matrix<n, m, R> {
        return a.mapNonZeroComponents{ $0 * r }
    }
    
    public static func * <p>(a: Matrix<n, m, R>, b: Matrix<m, p, R>) -> Matrix<n, p, R> {
        let cData = mul(a.data, b.data)
        return .init(size: (a.size.rows, b.size.cols), data: cData)
    }
    
    static func ⊕ <n1, m1>(a: Matrix<n, m, R>, b: Matrix<n1, m1, R>) -> DMatrix<R> {
        var x = a.as(DMatrix<R>.self)
        x.concatDiagonally(b)
        return x
    }
    
    static func ⊗ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
        let dB = B.asDynamicMatrix
        let cBlocks = A.data.mapValues { a in a * dB }
        
        let cRowBlocks = (0 ..< A.size.rows).map { i -> DMatrix<R> in
            let start = DMatrix<R>.zero(size: (B.size.rows, 0))
            return (0 ..< A.size.cols).reduce(into: start) { (res, j) in
                let c = MatrixCoord(i, j)
                let block = cBlocks[c] ?? .zero(size: B.size)
                res.concatHorizontally(block)
            }
        }
        
        let start = DMatrix<R>.zero(size: (0, A.size.cols * B.size.cols))
        return cRowBlocks.reduce(into: start) { (res, rowBlock) in
            res.concatVertically(rowBlock)
        }
    }
    
    public func makeIterator() -> AnyIterator<(row: Int, col: Int, value: R)> {
        return AnyIterator(data.sorted{ $0.key < $1.key }.lazy.compactMap{ (c, a) in a == .zero ? nil : (c.row, c.col, a) }.makeIterator())
    }
    
    public var description: String {
        let grid = self.grid
        return "[" + (0 ..< size.rows).map({ i in
            return (0 ..< size.cols).map({ j in
                return "\(grid[i * size.cols + j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public var detailDescription: String {
        if size.rows == 0 || size.cols == 0 {
            return "[\(size)]"
        } else {
            let grid = self.grid
            return "[\t" + (0 ..< size.rows).map({ i in
                return (0 ..< size.cols).map({ j in
                    return "\(grid[i * size.cols + j])"
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
    public init<S: Sequence>(_ grid: S) where S.Element == R {
        let (rows, cols) = (n.intValue, m.intValue)
        let data = Dictionary(pairs: grid.enumerated().map{ (k, a) -> (MatrixCoord, R) in
            let (i, j) = (k / cols, k % cols)
            return (MatrixCoord(i, j), a)
        })
        self.init(size: (rows, cols), data: data)
    }
    
    public init(_ grid: R...) {
        self.init(grid)
    }
    
    public init(generator g: (Int, Int) -> R) {
        let (rows, cols) = (n.intValue, m.intValue)
        let grid = (0 ..< rows * cols).map{ k -> R in
            let (i, j) = (k / cols, k % cols)
            return g(i, j)
        }
        self.init(grid)
    }
    
    public init(data: MatrixData) {
        let size = (n.intValue, m.intValue)
        self.init(size: size, data: data)
    }
    
    public static var zero: Matrix<n, m, R> {
        let size = (n.intValue, m.intValue)
        return ._zero(size: size)
    }
    
    public static func unit(_ i: Int, _ j: Int) -> Matrix<n, m, R> {
        let size = (n.intValue, m.intValue)
        return ._unit(size: size, coord: (i, j))
    }
}

extension Matrix: Monoid, Ring where n == m, n: StaticSizeType {
    public init(from a : 𝐙) {
        let data = (0 ..< n.intValue).map{ i in (MatrixCoord(i, i), R(from: a)) }
        self.init(data: Dictionary(pairs: data))
    }
    
    public static var identity: SquareMatrix<n, R> {
        return _identity(size: n.intValue)
    }
    
    public var isInvertible: Bool {
        return determinant.isInvertible
    }
    
    public var inverse: SquareMatrix<n, R>? {
        return _inverse
    }
    
    public var trace: R {
        return _trace
    }
    
    public var determinant: R {
        return _determinant
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

extension Matrix where n == DynamicSize, m == DynamicSize {
    public static func identity(size: Int) -> DMatrix<R> {
        return _identity(size: size)
    }
    
    public static func zero(size: (Int, Int)) -> DMatrix<R> {
        return _zero(size: size)
    }
    
    public static func unit(size: (Int, Int), coord: (Int, Int)) -> DMatrix<R> {
        return _unit(size: size, coord: coord)
    }
    
    public var inverse: DMatrix<R>? {
        return _inverse
    }
    
    public var trace: R {
        return _trace
    }
    
    public var determinant: R {
        return _determinant
    }
    
    public func pow(_ p: 𝐙) -> DMatrix<R> {
        assert(isSquare)
        assert(p >= 0)
        let I = DMatrix<R>.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
    }
    
    public mutating func concatVertically<n1, m1>(_ B: Matrix<n1, m1, R>) {
        assert(size.cols == B.size.cols)
        self.data.merge(B.data.mapKeys{ $0.shift(size.rows, 0) })
        self.size = (size.rows + B.size.rows, size.cols)
    }
    
    public mutating func concatHorizontally<n1, m1>(_ B: Matrix<n1, m1, R>) {
        assert(size.rows == B.size.rows)
        self.data.merge(B.data.mapKeys{ $0.shift(0, size.cols) })
        self.size = (size.rows, size.cols + B.size.cols)
    }
    
    public mutating func concatDiagonally<n1, m1>(_ B: Matrix<n1, m1, R>) {
        self.data.merge(B.data.mapKeys{ $0.shift(size.rows, size.cols) })
        self.size = (size.rows + B.size.cols, size.cols + B.size.cols)
    }
}

extension Matrix where R: EuclideanRing {
    public func eliminate(form: MatrixEliminationForm = .Diagonal, debug: Bool = false) -> MatrixEliminationResult<n, m, R> {
        let type: MatrixEliminator<R>.Type
        
        switch form {
        case .RowEchelon: type = RowEchelonEliminator.self
        case .ColEchelon: type = ColEchelonEliminator.self
        case .RowHermite: type = RowHermiteEliminator.self
        case .ColHermite: type = ColHermiteEliminator.self
        case .Smith:      type = SmithEliminator     .self
        default:          type = DiagonalEliminator  .self
        }
        
        let impl = MatrixImpl(rows: size.rows, cols: size.cols, components: nonZeroComponents)
        let elim = type.init(impl, debug: debug)
        elim.run()
        return MatrixEliminationResult(elim.target, elim.rowOps, elim.colOps)
    }
}

extension Matrix where R: RealSubset {
    public var asReal: Matrix<n, m, 𝐑> {
        return mapNonZeroComponents{ $0.asReal }
    }
}

extension Matrix where R: ComplexSubset {
    public var asComplex: Matrix<n, m, 𝐂> {
        return mapNonZeroComponents{ $0.asComplex }
    }
}

extension Matrix where R == 𝐂 {
    public var realPart: Matrix<n, m, 𝐑> {
        return mapNonZeroComponents{ $0.realPart }
    }
    
    public var imaginaryPart: Matrix<n, m, 𝐑> {
        return mapNonZeroComponents{ $0.imaginaryPart }
    }
    
    public var adjoint: Matrix<m, n, R> {
        return transposed.mapNonZeroComponents { $0.conjugate }
    }
}

extension Matrix: Codable where R: Codable {
    enum CodingKeys: String, CodingKey {
        case rows, cols, grid
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let rows = try c.decode(Int.self, forKey: .rows)
        let cols = try c.decode(Int.self, forKey: .cols)
        let grid = try c.decode([R].self, forKey: .grid)
        self.init(size: (rows, cols), grid: grid)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(size.rows, forKey: .rows)
        try c.encode(size.cols, forKey: .cols)
        try c.encode(grid, forKey: .grid)
    }
}

// TODO delete after refac complete

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)

extension Matrix {
    init(_ impl: MatrixImpl<R>) {
        self.init(rows: impl.rows, cols: impl.cols, components: impl.components)
    }
    
    public init(rows: Int, cols: Int, components: [MatrixComponent<R>]) {
        let data = components.map{ (i, j, a) in (MatrixCoord(i, j), a)}
        self.init(size: (rows, cols), data: Dictionary(pairs: data))
    }
    
    public var nonZeroComponents: [MatrixComponent<R>] {
        return exclude{ (_, _, a) in a == .zero }
    }
}

@_specialize(where R == Int)
fileprivate func mul<R: Ring>(_ A: [MatrixCoord : R], _ B: [MatrixCoord : R]) -> [MatrixCoord : R] {
    let aRows = A.group{ (c, _) in c.row }
    let bRows = B.group{ (c, _) in c.row }
    var cData = [MatrixCoord : R]()
    
    //       j              k
    //                    |          |
    //  i>|  a    *  |  j>| b   *    |
    //                    |          |
    //                    | *      * |
    //                    |          |
    //
    //                         ↓
    //                      k
    //                  i>| *   *  * |
    
    for (i, Ai) in aRows {
        for (c1, a_ij) in Ai {
            let j = c1.col
            guard let Bj = bRows[j] else {
                continue
            }
            for (c2, b_jk) in Bj {
                let k = c2.col
                let coord = MatrixCoord(i, k)
                cData[coord] = (cData[coord] ?? .zero) + a_ij * b_jk
            }
        }
    }
    
    return cData
}
