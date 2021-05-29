//
//  DefaultMatrixImpl.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

public struct DefaultMatrixImpl<R: Ring>: SparseMatrixImpl {
    public typealias BaseRing = R
    private typealias Data = [Coord : R]
    
    public var size: (rows: Int, cols: Int)
    private var data: Data
    
    private init(size: MatrixSize, data: Data) {
        assert(size.0 >= 0)
        assert(size.1 >= 0)
        assert(!data.contains{ $0.value.isZero })
        
        self.size = size
        self.data = data
    }
    
    public init(size: MatrixSize, initializer: (Initializer) -> Void) {
        var data: Data = [:]
        initializer { (i, j, a) in
            assert( 0 <= i && i < size.0 )
            assert( 0 <= j && j < size.1 )
            if !a.isZero {
                data[Coord(i, j)] = a
            }
        }
        self.init(size: size, data: data)
    }

    public subscript(i: Int, j: Int) -> R {
        get {
            data[i, j] ?? .zero
        } set {
            data[i, j] = (newValue.isZero) ? nil : newValue
        }
    }
    
    public var numberOfNonZeros: Int {
        data.count
    }
    
    public var nonZeroComponents: AnySequence<(row: Int, col: Int, value: R)> {
        AnySequence( data.lazy.map{ (c, a) -> MatrixEntry<R> in (c.row, c.col, a) } )
    }
    
    public var isZero: Bool {
        data.isEmpty
    }
    
    public var transposed: Self {
        .init(size: (size.cols, size.rows)) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in setEntry(j, i, a) }
        }
    }
    
    public func submatrix(rowRange: CountableRange<Int>, colRange: CountableRange<Int>) -> Self {
        let size = (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound)
        return .init(size: size ) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in
                if rowRange.contains(i) && colRange.contains(j) {
                    setEntry(i - rowRange.lowerBound, j - colRange.lowerBound, a)
                }
            }
        }
    }
    
    public var isInvertible: Bool {
        isSquare && determinant.isInvertible
    }
    
    public var inverse: Self? {
        if isSquare, let dInv = determinant.inverse {
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
    
    public var trace: BaseRing {
        assert(isSquare)
        return (0 ..< size.rows).sum { i in
            self[i, i]
        }
    }
    
    public var determinant: R {
        assert(isSquare)
        if size.rows == 0 {
            return .identity
        } else {
            return nonZeroEntries
                .filter{ (i, j, a) in i == 0 }
                .sum { (_, j, a) in a * cofactor(0, j) }
        }
    }
    
    private func cofactor(_ i0: Int, _ j0: Int) -> R {
        let ε = (-R.identity).pow(i0 + j0)
        let minor = Self(size: (size.rows - 1, size.cols - 1)) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in
                if i == i0 || j == j0 { return }
                let i1 = i < i0 ? i : i - 1
                let j1 = j < j0 ? j : j - 1
                setEntry(i1, j1, a)
            }
        }
        return ε * minor.determinant
    }
    
    public func concat(_ B: Self) -> Self {
        assert(size.rows == B.size.rows)
        
        let A = self
        return .init(size: (A.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j + A.size.cols, a) }
        }
    }
    
    public func stack(_ B: Self) -> Self {
        assert(size.cols == B.size.cols)
        
        let A = self
        return .init(size: (A.size.rows + B.size.rows, A.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i + A.size.rows, j, a) }
        }
    }
    
    public func permute(rowsBy p: Permutation<anySize>, colsBy q: Permutation<anySize>) -> Self {
        .init(size: size) { setEntry in
            nonZeroEntries.forEach{ (i, j, a) in
                setEntry(p[i], q[j], a)
            }
        }
    }

    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
    }
    
    public static prefix func - (a: Self) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in -a }
    }
    
    public static func -(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return a + (-b)
    }
    
    public static func * (r: R, a: DefaultMatrixImpl<R>) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in r * a }
    }
    
    public static func * (a: DefaultMatrixImpl<R>, r: R) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in a * r }
    }
    
    public static func *(a: Self, b: Self) -> Self {
        mulColBased(a, b)
    }
    
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)
    public static func mulRowBased(_ a: Self, _ b: Self) -> Self {
        assert(a.size.cols == b.size.rows)
        
        //       k              j
        //                    |          |
        //  i>|  a    *  |  k>| b   *    |
        //                    |          |
        //                    | *      * |
        //                    |          |
        //
        //                         ↓
        //                      j
        //                  i>| *   *  * |
        
        let aRows = a.data.group{ (e, _) in e.row } // [row : [index : value]]
        let bRows = b.data.group{ (e, _) in e.row }
        
        let data =
        Array(aRows).parallelFlatMap { (i, ai) -> [(Coord, R)] in
            ai.flatMap { (a_idx, a) -> [(Coord, R)] in
                let k = a_idx.col
                guard let bk = bRows[k] else {
                    return []
                }
                return bk.map { (b_idx, b) in
                    let j = b_idx.col
                    return ( Coord(i, j), a * b )
                }
            }
        }
        
        return .init(
            size: (a.size.rows, b.size.cols),
            data: Dictionary(data, uniquingKeysWith: +).exclude { $0.value.isZero }
        )
    }
    
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)
    private static func mulColBased(_ a: Self, _ b: Self) -> Self {
        assert(a.size.cols == b.size.rows)
        
        //      k              j        j
        // i |  a    *  |     | |    i |*|
        //   |          |   k |b|      | |
        //   |  *       |  x  | |  ->  | |
        //   |          |     |*|      |*|
        //   |  *       |     | |      | |
        //
        
        let aCols = a.data.group{ (e, _) in e.col }  // [col : [index : value]]
        let bCols = b.data.group{ (e, _) in e.col }
        
        let data =
        Array(bCols).parallelFlatMap { (j, bj) -> [(Coord, R)] in
            bj.flatMap { (b_idx, b) -> [(Coord, R)] in
                let k = b_idx.row
                guard let ak = aCols[k] else {
                    return []
                }
                return ak.map { (a_idx, a) in
                    let i = a_idx.row
                    return ( Coord(i, j), a * b )
                }
            }
        }
        
        return .init(
            size: (a.size.rows, b.size.cols),
            data: Dictionary(data, uniquingKeysWith: +).exclude{ $0.value.isZero }
        )
    }
    
    public static func ⊕ (A: Self, B: Self) -> Self {
        .init(size: (A.size.rows + B.size.rows, A.size.cols + B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, a) }
            B.nonZeroEntries.forEach { (i, j, a) in setEntry(i + A.size.rows, j + A.size.cols, a) }
        }
    }
    
    public static func ⊗ (A: Self, B: Self) -> Self {
        .init(size: (A.size.rows * B.size.rows, A.size.cols * B.size.cols)) { setEntry in
            A.nonZeroEntries.forEach { (i, j, a) in
                B.nonZeroEntries.forEach { (k, l, b) in
                    let p = i * B.size.rows + k
                    let q = j * B.size.cols + l
                    let c = a * b
                    setEntry(p, q, c)
                }
            }
        }
    }
    
    public var nonZeroEntries: AnySequence<MatrixEntry<R>> {
        AnySequence(data.map{ (c, a) in
            (c.row, c.col, a)
        })
    }
    
    private func mapNonZeroEntries(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, f(i, j, a)) }
        }
    }
    
    public func serialize() -> [R] {
        let (n, m) = self.size
        var grid = Array(repeating: R.zero, count: n * m)
        for (i, j, a) in nonZeroEntries {
            grid[i * m + j] = a
        }
        return grid
    }
}

fileprivate struct Coord: Hashable {
    let row, col: Int
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    var tuple: (Int, Int) {
        (row, col)
    }
}

fileprivate extension Dictionary where Key == Coord {
    subscript(_ i: Int, _ j: Int) -> Value? {
        get {
            self[Coord(i, j)]
        } set {
            self[Coord(i, j)] = newValue
        }
    }
}
