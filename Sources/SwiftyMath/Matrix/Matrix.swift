import Dispatch

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)
public typealias RowComponent<R: Ring> = (col: Int, value: R)
public typealias ColComponent<R: Ring> = (row: Int, value: R)

public typealias SquareMatrix<n: StaticSizeType, R: Ring> = Matrix<n, n, R>

public typealias Matrix1<R: Ring> = SquareMatrix<_1, R>
public typealias Matrix2<R: Ring> = SquareMatrix<_2, R>
public typealias Matrix3<R: Ring> = SquareMatrix<_3, R>
public typealias Matrix4<R: Ring> = SquareMatrix<_4, R>

public typealias DMatrix<R: Ring> = Matrix<DynamicSize, DynamicSize, R>

public struct Matrix<n: SizeType, m: SizeType, R: Ring>: SetType {
    public typealias BaseRing = R
    public typealias Impl = DefaultMatrixImpl<R>
    internal var impl: Impl
    
    internal init(impl: Impl) {
        assert(n.isDynamic || n.intValue == impl.size.rows)
        assert(m.isDynamic || m.intValue == impl.size.cols)
        self.impl = impl
    }
    
    public init(size: (Int, Int), initializer: ( (Int, Int, R) -> Void ) -> Void) {
        let impl = Impl(size: size, initializer: initializer)
        self.init(impl: impl)
    }
    
    public init(size: (Int, Int), concurrentIterations n: Int, initializer: @escaping (Int, (Int, Int, R) -> Void ) -> Void) {
        let queue = DispatchQueue(label: "MatrixInit", qos: .userInteractive)
        self.init(size: size) { setEntry in
            DispatchQueue.concurrentPerform(iterations: n) { itr in
                initializer(itr) { (i: Int, j: Int, r: R) -> Void in
                    queue.sync { setEntry(i, j, r) }
                }
            }
        }
    }
    
    public init<S: Sequence>(size: (Int, Int), components: S) where S.Element == MatrixComponent<R> {
        self.init(size: size) { setEntry in
            components.forEach { (i, j, a) in setEntry(i, j, a) }
        }
    }
    
    public init<S: Sequence>(size: (Int, Int), grid: S) where S.Element == R {
        let cols = size.1
        self.init(size: size) { setEntry in
            grid.enumerated().forEach { (k, a) in
                let (i, j) = (k / cols, k % cols)
                setEntry(i, j, a)
            }
        }
    }
    
    public init(size: (Int, Int), diagonal d: [R]) {
        self.init(size: size) { setEntry in
            d.enumerated().forEach{ (i, a) in setEntry(i, i, a) }
        }
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
    
    public var nonZeroComponents: AnySequence<MatrixComponent<R>> {
        impl.nonZeroComponents
    }
    
    public var isZero: Bool {
        nonZeroComponents.isEmpty
    }
    
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var isIdentity: Bool {
        isSquare && nonZeroComponents.allSatisfy{ (i, j, a) in (i == j && a.isIdentity) }
    }
    
    public var isDiagonal: Bool {
        nonZeroComponents.allSatisfy{ (i, j, a) in i == j }
    }
    
    public var diagonalComponents: [R] {
        let r = Swift.min(size.rows, size.cols)
        return (0 ..< r).map{ i in self[i, i] }
    }
    
    public static func zero(size: (Int, Int)) -> Self {
        .init(size: size) { _ in () }
    }
    
    public static func identity(size n: Int) -> Self {
        .init(size: (n, n)) { setEntry in
            for i in 0 ..< n {
                setEntry(i, i, .identity)
            }
        }
    }
    
    public static func unit(size: (Int, Int), coord: (Int, Int)) -> Self {
        .init(size: size) { setEntry in
            setEntry(coord.0, coord.1, .identity)
        }
    }
    
    public var transposed: Matrix<m, n, R> {
        .init(size: (size.cols, size.rows)) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in setEntry(j, i, a) }
        }
    }
    
    public func rowVector(_ i: Int) -> RowVector<m, R> {
        submatrix(rowRange: i ..< i + 1, colRange: 0 ..< size.cols).as(RowVector<m, R>.self)
    }
    
    public func colVector(_ j: Int) -> ColVector<n, R> {
        submatrix(rowRange: 0 ..< size.rows, colRange: j ..< j + 1).as(ColVector<n, R>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>) -> Matrix<DynamicSize, m, R> {
        submatrix(rowRange: rowRange, colRange: 0 ..< size.cols).as(Matrix<DynamicSize, m, R>.self)
    }
    
    public func submatrix(colRange: CountableRange<Int>) -> Matrix<n, DynamicSize, R> {
        submatrix(rowRange: 0 ..< size.rows, colRange: colRange).as(Matrix<n, DynamicSize, R>.self)
    }
    
    public func submatrix(rowRange: CountableRange<Int>,  colRange: CountableRange<Int>) -> DMatrix<R> {
        let size = (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound)
        return .init(size: size ) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in
                if rowRange.contains(i) && colRange.contains(j) {
                    setEntry(i - rowRange.lowerBound, j - colRange.lowerBound, a)
                }
            }
        }
    }
    
    public func splitIntoRowVectors() -> [RowVector<m, R>] {
        let rows = nonZeroComponents.group { $0.row }
        return (0 ..< size.rows).map { i in
            RowVector(size: (1, size.cols)) { setEntry in
                rows[i]?.forEach { (_, j, a) in setEntry(0, j, a) }
            }
        }
    }
    
    public func splitIntoColVectors() -> [ColVector<m, R>] {
        let cols = nonZeroComponents.group { $0.col }
        return (0 ..< size.cols).map { j in
            ColVector(size: (size.rows, 1)) { setEntry in
                cols[j]?.forEach { (i, _, a) in setEntry(i, 0, a) }
            }
        }
    }
    
    public func splitHorizontally(at j0: Int) -> (Matrix<n, DynamicSize, R>, Matrix<n, DynamicSize, R>) {
        let (Ac, Bc) = nonZeroComponents.split { $0.col < j0 }
        let A = Matrix<n, DynamicSize, R>(size: (size.rows, j0)) { setEntry in
            Ac.forEach { (i, j, a) in setEntry(i, j, a) }
        }
        let B = Matrix<n, DynamicSize, R>(size: (size.rows, size.cols - j0)) { setEntry in
            Bc.forEach { (i, j, a) in setEntry(i, j - j0, a) }
        }
        return (A, B)
    }
    
    public func splitVertically(at i0: Int) -> (Matrix<DynamicSize, m, R>, Matrix<DynamicSize, m, R>) {
        let (Ac, Bc) = nonZeroComponents.split { $0.row < i0 }
        let A = Matrix<DynamicSize, m, R>(size: (i0, size.cols)) { setEntry in
            Ac.forEach { (i, j, a) in setEntry(i, j, a) }
        }
        let B = Matrix<DynamicSize, m, R>(size: (size.rows - i0, size.cols)) { setEntry in
            Bc.forEach { (i, j, a) in setEntry(i - i0, j, a) }
        }
        return (A, B)
    }
    
    public func permuteRows(by σ: Permutation<n>) -> Self {
        .init(size: size) { setEntry in
            nonZeroComponents.forEach{ (i, j, a) in
                setEntry(σ[i], j, a)
            }
        }
    }
    
    public func permuteCols(by σ: Permutation<m>) -> Self {
        .init(size: size) { setEntry in
            nonZeroComponents.forEach{ (i, j, a) in
                setEntry(i, σ[j], a)
            }
        }
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.impl == b.impl
    }
    
    public static func +(a: Self, b: Self) -> Matrix {
        .init(impl: a.impl + b.impl)
    }
    
    public prefix static func -(a: Self) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in -a }
    }
    
    public static func -(a: Self, b: Self) -> Self {
        a + (-b)
    }
    
    public static func *(r: R, a: Self) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in r * a }
    }
    
    public static func *(a: Self, r: R) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in a * r }
    }
    
    public static func * <p>(a: Matrix<n, m, R>, b: Matrix<m, p, R>) -> Matrix<n, p, R> {
        .init(impl: a.impl * b.impl)
    }
    
    public func concatVertically<n1>(_ B: Matrix<n1, m, R>) -> Matrix<DynamicSize, m, R> {
        let A = self
        assert(A.size.cols == B.size.cols)
        
        return .init(size: (A.size.rows + B.size.rows, A.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i + A.size.rows, j, a) }
        }
    }

    public func concatHorizontally<m1>(_ B: Matrix<n, m1, R>) -> Matrix<n, DynamicSize, R> {
        let A = self
        assert(A.size.rows == B.size.rows)
        
        return .init(size: (A.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j + A.size.cols, a) }
        }
    }

    public static func ⊕ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
        .init(size: (A.size.rows + B.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i + A.size.rows, j + A.size.cols, a) }
        }
    }

    public static func ⊗ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
        .init(size: (A.size.rows * B.size.rows, A.size.cols * B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in
                B.nonZeroComponents.forEach { (k, l, b) in
                    let p = i * B.size.rows + k
                    let q = j * B.size.cols + l
                    let c = a * b
                    setEntry(p, q, c)
                }
            }
        }
    }
    
    public func mapNonZeroComponents(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, f(i, j, a)) }
        }
    }

    public func `as`<n1, m1>(_ type: Matrix<n1, m1, R>.Type) -> Matrix<n1, m1, R> {
        Matrix<n1, m1, R>(impl: impl)
    }
    
    public var asDynamicMatrix: DMatrix<R> {
        self.as(DMatrix.self)
    }
    
    public var asArray: [R] {
        (0 ..< size.rows * size.cols).map { k in
            let (i, j) = (k / size.cols, k % size.cols)
            return self[i, j]
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

fileprivate extension Matrix {
    var _determinant: R {
        assert(isSquare)
        if size.rows == 0 {
            return .identity
        } else {
            return nonZeroComponents
                .filter{ (i, j, a) in i == 0 }
                .sum { (_, j, a) in a * cofactor(0, j) }
        }
    }
    
    var _inverse: Self? {
        assert(isSquare)
        if let dInv = _determinant.inverse {
            return .init(size: size) { setEntry in
                ((0 ..< size.rows) * (0 ..< size.cols)).forEach { (i, j) in
                    let a = dInv * cofactor(j, i)
                    setEntry(i, j, a)
                }
            }
        } else {
            return nil
        }
    }
    
    func cofactor(_ i0: Int, _ j0: Int) -> R {
        assert(isSquare && size.rows > 0)

        let ε = (-R.identity).pow(i0 + j0)
        let minor = DMatrix<R>(size: (size.rows - 1, size.cols - 1)) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in
                if i == i0 || j == j0 { return }
                let i1 = i < i0 ? i : i - 1
                let j1 = j < j0 ? j : j - 1
                setEntry(i1, j1, a)
            }
        }
        return ε * minor._determinant
    }
}

extension Matrix: AdditiveGroup, Module where n: StaticSizeType, m: StaticSizeType {
    public init(initializer: ( (Int, Int, R) -> Void ) -> Void) {
        let size = (n.intValue, m.intValue)
        self.init(size: size, initializer: initializer)
    }
        
    public init<S: Sequence>(_ grid: S) where S.Element == R {
        let size = (n.intValue, m.intValue)
        self.init(size: size, grid: grid)
    }
    
    public init(_ grid: R...) {
        self.init(grid)
    }
    
    public init(diagonal d: [R]) {
        let size = (n.intValue, m.intValue)
        self.init(size: size, diagonal: d)
    }
    
    public static var zero: Self {
        .init([])
    }
    
    public static func unit(_ i: Int, _ j: Int) -> Self {
        let size = (n.intValue, m.intValue)
        return .init(size: size) { setEntry in
            setEntry(i, j, .identity)
        }
    }
}

extension Matrix: Multiplicative, Monoid, Ring where n == m, n: StaticSizeType {
    public init(from a : 𝐙) {
        let size = (n.intValue, n.intValue)
        self.init(size: size) { setEntry in
            (0 ..< n.intValue).forEach { i in setEntry(i, i, R(from: a)) }
        }
    }
    
    public var determinant: R {
        _determinant
    }

    public var isInvertible: Bool {
        _determinant.isInvertible
    }
    
    public var inverse: Self? {
        _inverse
    }
    
    public var trace: R {
        diagonalComponents.sumAll()
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        nonZeroComponents.anyElement?.value ?? .zero
    }
}

extension Matrix where n == DynamicSize, m == DynamicSize {
    public var determinant: R {
        assert(isSquare)
        return _determinant
    }

    public var isInvertible: Bool {
        isSquare && _determinant.isInvertible
    }
    
    public var inverse: Self? {
        assert(isSquare)
        return _inverse
    }
    
    public var trace: R {
        assert(isSquare)
        return diagonalComponents.sumAll()
    }
    
    public func pow(_ p: 𝐙) -> Self {
        assert(isSquare)
        assert(p >= 0)
        let I = DMatrix<R>.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
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
