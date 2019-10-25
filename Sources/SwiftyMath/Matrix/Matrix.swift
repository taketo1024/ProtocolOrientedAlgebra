import Dispatch

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
        impl.diagonalComponents
    }
    
    fileprivate static func _identity(size n: Int) -> Self {
        .init(size: (n, n)) { setEntry in
            for i in 0 ..< n {
                setEntry(i, i, .identity)
            }
        }
    }
    
    public var transposed: Matrix<m, n, R> {
        .init(impl: impl.transposed)
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
        assert(A.size.cols == B.size.cols)
        
        return .init(size: (A.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j + A.size.cols, a) }
        }
    }

    public static func ⊕ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
        return .init(size: (A.size.rows + B.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroComponents.forEach { (i, j, a) in setEntry(i + A.size.rows, j + A.size.cols, a) }
        }
    }

    public static func ⊗ <n1, m1>(A: Matrix<n, m, R>, B: Matrix<n1, m1, R>) -> DMatrix<R> {
        .init(size: (A.size.rows * B.size.rows, A.size.cols * B.size.cols)) { setEntry in
            A.nonZeroComponents.forEach { (i, j, a) in
                B.nonZeroComponents.forEach { (k, l, b) in
                    setEntry(i * B.size.rows + k, j * B.size.cols + l, a * b)
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
    
    public var isInvertible: Bool {
        impl.isInvertible
    }
    
    public var inverse: Self? {
        impl.inverse.map{ .init(impl: $0) }
    }
    
    public var trace: R {
        diagonalComponents.sumAll()
    }
    
    public var determinant: R {
        impl.determinant
    }
}

extension Matrix where n == m, n == _1 {
    public var asScalar: R {
        nonZeroComponents.anyElement?.value ?? .zero
    }
}

extension Matrix where n == DynamicSize, m == DynamicSize {
    public static func zero(size: (Int, Int)) -> Self {
        .init(size: size) { _ in () }
    }
    
    public static func identity(size n: Int) -> Self {
        .init(size: (n, n)) { setEntry in
            (0 ..< n).forEach { i in setEntry(i, i, .identity) }
        }
    }
    
    public static func unit(size: (Int, Int), coord: (Int, Int)) -> Self {
        .init(size: size) { setEntry in
            setEntry(coord.0, coord.1, .identity)
        }
    }
    
    public var inverse: Self? {
        assert(isSquare)
        return impl.inverse.map{ .init(impl: $0) }
    }
    
    public var trace: R {
        assert(isSquare)
        return diagonalComponents.sumAll()
    }
    
    public var determinant: R {
        assert(isSquare)
        return impl.determinant
    }
    
    public func pow(_ p: 𝐙) -> Self {
        assert(isSquare)
        assert(p >= 0)
        let I = DMatrix<R>.identity(size: size.rows)
        return (0 ..< p).reduce(I){ (res, _) in self * res }
    }
}

//extension Matrix where R: RealSubset {
//    public var asReal: Matrix<n, m, 𝐑> {
//        mapNonZeroComponents { $0.asReal }
//    }
//}
//
//extension Matrix where R: ComplexSubset {
//    public var asComplex: Matrix<n, m, 𝐂> {
//        mapNonZeroComponents { $0.asComplex }
//    }
//}
//
//extension Matrix where R == 𝐂 {
//    public var realPart: Matrix<n, m, 𝐑> {
//        mapNonZeroComponents { $0.realPart }
//    }
//
//    public var imaginaryPart: Matrix<n, m, 𝐑> {
//        mapNonZeroComponents { $0.imaginaryPart }
//    }
//
//    public var adjoint: Matrix<m, n, R> {
//        transposed.mapNonZeroComponents { $0.conjugate }
//    }
//}

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

public typealias MatrixComponent<R: Ring> = (row: Int, col: Int, value: R)
