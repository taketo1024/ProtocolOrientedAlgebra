import Foundation

public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>
public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)

internal struct MatrixCoord: Hashable, Comparable, Codable, CustomStringConvertible {
    public let row, col: Int
    public init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    public func shift(_ i: Int, _ j: Int) -> MatrixCoord {
        MatrixCoord(row + i, col + j)
    }
    
    public var transposed: MatrixCoord {
        MatrixCoord(col, row)
    }
    
    public static func < (lhs: MatrixCoord, rhs: MatrixCoord) -> Bool {
        (lhs.row < rhs.row) || (lhs.row == rhs.row && lhs.col < rhs.col)
    }
    
    public var description: String {
        "(\(row), \(col))"
    }
}

internal typealias MatrixData<R: Ring> = [MatrixCoord : R]

public struct Matrix<n: SizeType, m: SizeType, R: Ring>: SetType {
    public typealias CoeffRing = R
    public var size: (rows: Int, cols: Int)
    internal var data: MatrixData<R>
    
    internal init(size: (Int, Int), data: MatrixData<R>, zerosExcluded: Bool = false) {
        assert(n.isDynamic || n.intValue == size.0)
        assert(m.isDynamic || m.intValue == size.1)
        assert(data.keys.allSatisfy{ c in (0 ..< size.0).contains(c.row) && (0 ..< size.1).contains(c.col)})
        assert(!zerosExcluded || data.values.allSatisfy{ $0 != .zero} )
        
        self.size = size
        self.data = zerosExcluded ? data : data.exclude{ (_, a) in a == .zero }
    }
    
    public init(size: (Int, Int), components: [MatrixComponent<R>], zerosExcluded: Bool = false) {
        let data = components.map{ (i, j, a) in (MatrixCoord(i, j), a)}
        self.init(size: size, data: Dictionary(pairs: data), zerosExcluded: zerosExcluded)
    }
    
    // MEMO: do not use for a large matrix.
    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == R {
        let cols = size.1
        let data = grid.enumerated()
            .exclude{ (_, a) in a == .zero }
            .map{ (k, a) -> (MatrixCoord, R) in
                let (i, j) = (k / cols, k % cols)
                return (MatrixCoord(i, j), a)
            }
        self.init(size: size, data: Dictionary(pairs: data), zerosExcluded: true)
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
    
    public init(size: (Int, Int), diagonal d: [R]) {
        let comps = d.enumerated().map{ (i, a) -> MatrixComponent<R> in (i, i, a) }
        self.init(size: size, components: comps)
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            data[MatrixCoord(i, j)] ?? .zero
        } set {
            data[MatrixCoord(i, j)] = (newValue != .zero) ? newValue : nil
        }
    }
    
    public var isZero: Bool {
        data.allSatisfy{ (_, a) in a == .zero }
    }
    
    public var isIdentity: Bool {
        data.allSatisfy{ (c, a) in (c.row == c.col && a == .identity) || (c.row != c.col && a == .zero) }
    }
    
    public var isDiagonal: Bool {
        data.allSatisfy{ (c, a) in (c.row == c.col) || (a == .zero) }
    }
    
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var diagonal: [R] {
        (0 ..< Swift.min(size.rows, size.cols)).map{ i in self[i, i] }
    }
    
    public var transposed: Matrix<m, n, R> {
        Matrix<m, n, R>(size: (size.cols, size.rows), data: data.mapKeys{ $0.transposed } )
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
        
        return rowVector(0).components.sum{ (_, j, a) in a * _cofactor(0, j) }
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
        ColVector(size: (size.rows, 1), data: subData(rowRange: 0 ..< size.rows, colRange: j ..< j + 1))
    }
    
    public func rowVector(_ i: Int) -> RowVector<m, R> {
        RowVector(size: (1, size.cols), data: subData(rowRange: i ..< i + 1, colRange: 0 ..< size.cols))
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> Matrix<DynamicSize, m, R> {
        .init(size: (rowRange.upperBound - rowRange.lowerBound, size.cols), data: subData(rowRange: rowRange, colRange: 0 ..< size.cols))
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> Matrix<n, DynamicSize, R> {
        .init(size: (size.rows, colRange.upperBound - colRange.lowerBound), data: subData(rowRange: 0 ..< size.rows, colRange: colRange))
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> DMatrix<R> {
        .init(size: (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound), data: subData(rowRange: rowRange, colRange: colRange))
    }
    
    private func subData(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> MatrixData<R> {
        data.filter{ (c, _) in
            rowRange.contains(c.row) && colRange.contains(c.col)
        }.mapKeys{ c in
            MatrixCoord(c.row - rowRange.lowerBound, c.col - colRange.lowerBound)
        }
    }
    
    public var components: AnySequence<MatrixComponent<R>> {
        AnySequence(data.lazy.map{ (c, a) -> MatrixComponent<R> in (c.row, c.col, a) })
    }
    
    public func mapComponents<R2>(zerosExcluded: Bool = false, _ f: (R) -> R2) -> Matrix<n, m, R2> {
        .init(size: size, data: data.mapValues(f), zerosExcluded: zerosExcluded)
    }
    
    public func `as`<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix<n, m, R>(size: size, data: data)
    }
    
    public var asDynamicMatrix: DMatrix<R> {
        self.as(DMatrix<R>.self)
    }
    
    public var asArray: [R] {
        (0 ..< size.rows * size.cols).map { k in
            let (i, j) = (k / size.cols, k % size.cols)
            return self[i, j]
        }
    }
    
    fileprivate static func _identity(size: Int) -> Matrix<n, m, R> {
        let data = (0 ..< size).map{ i in (MatrixCoord(i, i), R.identity) }
        return Matrix(size: (size, size), data: Dictionary(pairs: data))
    }
    
    fileprivate static func _zero(size: (Int, Int)) -> Matrix<n, m, R> {
        Matrix(size: size, data: [:])
    }
    
    fileprivate static func _unit(size: (Int, Int), coord: (Int, Int)) -> Matrix<n, m, R> {
        Matrix(size: size, data: [MatrixCoord(coord.0, coord.1): .identity])
    }
    
    public static func ==(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Bool {
        a.data.exclude{ $0.value == .zero } == b.data.exclude{ $0.value == .zero }
    }
    
    public static func +(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        assert(a.size == b.size)
        return Matrix(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +))
    }
    
    public prefix static func -(a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        a.mapComponents(zerosExcluded: true, (-))
    }
    
    public static func -(a: Matrix<n, m, R>, b: Matrix<n, m, R>) -> Matrix<n, m, R> {
        a + (-b)
    }
    
    public static func *(r: R, a: Matrix<n, m, R>) -> Matrix<n, m, R> {
        a.mapComponents{ r * $0 }
    }
    
    public static func *(a: Matrix<n, m, R>, r: R) -> Matrix<n, m, R> {
        a.mapComponents{ $0 * r }
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
    
    public var description: String {
        let grid = self.asArray
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
            let grid = self.asArray
            return "[\t" + (0 ..< size.rows).map({ i in
                (0 ..< size.cols).map({ j in
                    "\(grid[i * size.cols + j])"
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
        let size = (n.intValue, m.intValue)
        self.init(size: size, grid: grid)
    }
    
    public init(_ grid: R...) {
        self.init(grid)
    }
    
    public init(generator g: (Int, Int) -> R) {
        let size = (n.intValue, m.intValue)
        self.init(size: size, generator: g)
    }
    
    public init(diagonal d: [R]) {
        let size = (n.intValue, m.intValue)
        self.init(size: size, diagonal: d)
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
        let size = (n.intValue, n.intValue)
        let data = (a != .zero) ? (0 ..< n.intValue).map{ i in (MatrixCoord(i, i), R(from: a)) } : []
        self.init(size: size, data: Dictionary(pairs: data), zerosExcluded: true)
    }
    
    public static var identity: SquareMatrix<n, R> {
        _identity(size: n.intValue)
    }
    
    public var isInvertible: Bool {
        determinant.isInvertible
    }
    
    public var inverse: SquareMatrix<n, R>? {
        _inverse
    }
    
    public var trace: R {
        _trace
    }
    
    public var determinant: R {
        _determinant
    }
    
    public func pow(_ n: 𝐙) -> SquareMatrix<n, R> {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        self[0, 0]
    }
}

extension Matrix where n == DynamicSize, m == DynamicSize {
    public static func identity(size: Int) -> DMatrix<R> {
        _identity(size: size)
    }
    
    public static func zero(size: (Int, Int)) -> DMatrix<R> {
        _zero(size: size)
    }
    
    public static func unit(size: (Int, Int), coord: (Int, Int)) -> DMatrix<R> {
        _unit(size: size, coord: coord)
    }
    
    public var inverse: DMatrix<R>? {
        _inverse
    }
    
    public var trace: R {
        _trace
    }
    
    public var determinant: R {
        _determinant
    }
    
    public func pow(_ p: 𝐙) -> DMatrix<R> {
        assert(isSquare)
        assert(p >= 0)
        let I = DMatrix<R>.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
    }
    
    public mutating func transpose() {
        self.size = (size.cols, size.rows)
        self.data = data.mapKeys{ $0.transposed }
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
    
    public static func concat(_ vs: [DVector<R>]) -> DMatrix<R> {
        if vs.isEmpty {
            return .zero(size: (0, 0))
        }
        
        let size = (vs.first!.size.rows, vs.count)
        let comps = vs.enumerated().flatMap{ (j, v) in v.components.map{ (i, _, a) in MatrixComponent(i, j, a) } }
        return .init(size: size, components: comps)
    }
}

extension Matrix where R: EuclideanRing {
    public func eliminate(mode: MatrixEliminator<R>.Mode = .balanced, form: MatrixEliminator<R>.Form = .Diagonal, debug: Bool = false) -> MatrixEliminationResult<n, m, R> {
        let e: MatrixEliminator<R> = {
            switch form {
            case .RowEchelon: return RowEchelonEliminator(mode: mode, debug: debug)
            case .ColEchelon: return ColEchelonEliminator(mode: mode, debug: debug)
            case .RowHermite: return RowHermiteEliminator(mode: mode, debug: debug)
            case .ColHermite: return ColHermiteEliminator(mode: mode, debug: debug)
            case .Smith:      return SmithEliminator     (mode: mode, debug: debug)
            default:          return DiagonalEliminator  (mode: mode, debug: debug)
            }
        }()
        
        return e.run(target: self)
    }
}

extension Matrix where R: RealSubset {
    public var asReal: Matrix<n, m, 𝐑> {
        mapComponents(zerosExcluded: true){ $0.asReal }
    }
}

extension Matrix where R: ComplexSubset {
    public var asComplex: Matrix<n, m, 𝐂> {
        mapComponents(zerosExcluded: true){ $0.asComplex }
    }
}

extension Matrix where R == 𝐂 {
    public var realPart: Matrix<n, m, 𝐑> {
        mapComponents{ $0.realPart }
    }
    
    public var imaginaryPart: Matrix<n, m, 𝐑> {
        mapComponents{ $0.imaginaryPart }
    }
    
    public var adjoint: Matrix<m, n, R> {
        transposed.mapComponents(zerosExcluded: true) { $0.conjugate }
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
        try c.encode(asArray, forKey: .grid)
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
