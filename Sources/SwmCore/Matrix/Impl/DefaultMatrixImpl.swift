//
//  DefaultMatrixImpl.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

public struct DefaultMatrixImpl<R: Ring>: SparseMatrixImpl {
    public typealias BaseRing = R
    fileprivate typealias Data = [Index : R]
    
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
                data[Index(i, j)] = a
            }
        }
        self.init(size: size, data: data)
    }

    public subscript(i: Int, j: Int) -> R {
        get {
            data[Index(i, j)] ?? .zero
        } set {
            data[Index(i, j)] = (newValue.isZero) ? nil : newValue
        }
    }
    
    public var numberOfNonZeros: Int {
        data.count
    }
    
    public var nonZeroEntries: AnySequence<MatrixEntry<R>> {
        AnySequence(NonZeroEntryIterator(data))
    }
    
    public var isZero: Bool {
        data.isEmpty
    }
    
    public var isIdentity: Bool {
        data.allSatisfy { (e, a) in
            e.row == e.col && a.isIdentity
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
        Array(aRows).parallelFlatMap { (i, ai) -> [(Index, R)] in
            ai.flatMap { (a_idx, a) -> [(Index, R)] in
                let k = a_idx.col
                guard let bk = bRows[k] else {
                    return []
                }
                return bk.map { (b_idx, b) in
                    let j = b_idx.col
                    return ( Index(i, j), a * b )
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
        Array(bCols).parallelFlatMap { (j, bj) -> [(Index, R)] in
            bj.flatMap { (b_idx, b) -> [(Index, R)] in
                let k = b_idx.row
                guard let ak = aCols[k] else {
                    return []
                }
                return ak.map { (a_idx, a) in
                    let i = a_idx.row
                    return ( Index(i, j), a * b )
                }
            }
        }
        
        return .init(
            size: (a.size.rows, b.size.cols),
            data: Dictionary(data, uniquingKeysWith: +).exclude{ $0.value.isZero }
        )
    }
    
    private func mapNonZeroEntries(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in setEntry(i, j, f(i, j, a)) }
        }
    }
    
    fileprivate struct Index: Hashable {
        let row, col: Int
        init(_ row: Int, _ col: Int) {
            self.row = row
            self.col = col
        }
    }
    
    fileprivate struct NonZeroEntryIterator: Sequence, IteratorProtocol {
        typealias Element = MatrixEntry<R>
        
        var itr: Data.Iterator
        init(_ data: Data) {
            self.itr = data.makeIterator()
        }
        
        mutating func next() -> MatrixEntry<R>? {
            if let (idx, a) = itr.next() {
                return (idx.row, idx.col, a)
            } else {
                return nil
            }
        }
    }
}
