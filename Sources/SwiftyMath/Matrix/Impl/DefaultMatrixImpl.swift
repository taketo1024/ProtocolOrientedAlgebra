//
//  DefaultMatrixImpl.swift
//  
//
//  Created by Taketo Sano on 2021/05/11.
//

public struct DefaultMatrixImpl<R: Ring>: MatrixImpl {
    public typealias BaseRing = R
    private typealias Data = [Coord : R]
    
    public var size: (rows: Int, cols: Int)
    private var data: Data
    
    private init(size: (Int, Int), data: Data) {
        assert(size.0 >= 0)
        assert(size.1 >= 0)
        assert(!data.contains{ $0.value.isZero })
        
        self.size = size
        self.data = data
    }
    
    public init(size: (Int, Int), initializer: (Initializer) -> Void) {
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
    
    public var isZero: Bool {
        data.isEmpty
    }
    
    public var transposed: Self {
        .init(size: (size.cols, size.rows)) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in setEntry(j, i, a) }
        }
    }
    
    public func submatrix(rowRange: CountableRange<Int>, colRange: CountableRange<Int>) -> Self {
        let size = (rowRange.upperBound - rowRange.lowerBound, colRange.upperBound - colRange.lowerBound)
        return .init(size: size ) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in
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
    
    public var determinant: R {
        assert(isSquare)
        if size.rows == 0 {
            return .identity
        } else {
            return nonZeroComponents
                .filter{ (i, j, a) in i == 0 }
                .sum { (_, j, a) in a * cofactor(0, j) }
        }
    }
    
    private func cofactor(_ i0: Int, _ j0: Int) -> R {
        let ε = (-R.identity).pow(i0 + j0)
        let minor = Self(size: (size.rows - 1, size.cols - 1)) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in
                if i == i0 || j == j0 { return }
                let i1 = i < i0 ? i : i - 1
                let j1 = j < j0 ? j : j - 1
                setEntry(i1, j1, a)
            }
        }
        return ε * minor.determinant
    }
    
    public var nonZeroComponents: AnySequence<(row: Int, col: Int, value: R)> {
        AnySequence( data.lazy.map{ (c, a) -> MatrixComponent<R> in (c.row, c.col, a) } )
    }
    
    public func mapNonZeroComponents(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size) { setEntry in
            nonZeroComponents.forEach { (i, j, a) in setEntry(i, j, f(i, j, a)) }
        }
    }
    
    public func serialize() -> [R] {
        let (n, m) = self.size
        var grid = Array(repeating: R.zero, count: n * m)
        for (i, j, a) in nonZeroComponents {
            grid[i * m + j] = a
        }
        return grid
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
    }
    
    public static prefix func - (a: Self) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in -a }
    }
    
    public static func * (r: R, a: DefaultMatrixImpl<R>) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in r * a }
    }
    
    public static func * (a: DefaultMatrixImpl<R>, r: R) -> Self {
        a.mapNonZeroComponents{ (_, _, a) in a * r }
    }
    
    @_specialize(where R == 𝐅₂)
    public static func *(a: Self, b: Self) -> Self {
        assert(a.size.cols == b.size.rows)
        
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
        
        let aRows = a.data.group{ (e, _) in e.row }
        let bRows = b.data.group{ (e, _) in e.row }
        
        let data =
        Array(aRows).parallelFlatMap { (i, Ai) -> [(Coord, R)] in
            Ai.flatMap { (e1, a) -> [(Coord, R)] in
                let j = e1.col
                guard let Bj = bRows[j] else {
                    return []
                }
                return Bj.map { (e2, b) in
                    let k = e2.col
                    return ( Coord(i, k), a * b )
                }
            }
            .group(by: { (e, _) in e.col } )
            .compactMap { (k, list) -> (Coord, R)? in
                let sum = list.sum { (_, c) in c }
                return sum.isZero ? nil : (Coord(i, k), sum)
            }
        }
        
        return .init(size: (a.size.rows, b.size.cols), data: Dictionary(pairs: data))
    }
    
    public var description: String {
        "[" + (0 ..< size.rows).map({ i in
            return (0 ..< size.cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public var detailDescription: String {
        if size.rows == 0 || size.cols == 0 {
            return "[\(size)]"
        } else {
            return "[\t" + (0 ..< size.rows).map({ i in
                (0 ..< size.cols).map({ j in
                    "\(self[i, j])"
                }).joined(separator: ",\t")
            }).joined(separator: "\n\t") + "]"
        }
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
