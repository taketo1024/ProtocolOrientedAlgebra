//
//  DefaultMatrixImpl.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

//  Implemented with DOK (dictionary of keys) format.
//  https://en.wikipedia.org/wiki/Sparse_matrix#Dictionary_of_keys_(DOK)
//  Not intended for fast computation.

public struct DefaultMatrixImpl<R: Ring>: SparseMatrixImpl {
    public typealias BaseRing = R
    public typealias Data = [Index : R]
    
    public var size: (rows: Int, cols: Int)
    public private(set) var data: Data
    
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
        @inlinable
        get {
            data[Index(i, j)] ?? .zero
        } set {
            data[Index(i, j)] = (newValue.isZero) ? nil : newValue
        }
    }
    
    @inlinable
    public var numberOfNonZeros: Int {
        data.count
    }
    
    public var nonZeroEntries: AnySequence<MatrixEntry<R>> {
        AnySequence(NonZeroEntryIterator(data))
    }
    
    @inlinable
    public var isZero: Bool {
        data.isEmpty
    }
    
    @inlinable
    public var isIdentity: Bool {
        data.allSatisfy { (e, a) in
            e.row == e.col && a.isIdentity
        }
    }
    
    @inlinable
    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
    }
    
    @inlinable
    public static prefix func - (a: Self) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in -a }
    }
    
    @inlinable
    public static func -(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return a + (-b)
    }
    
    @inlinable
    public static func * (r: R, a: DefaultMatrixImpl<R>) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in r * a }
    }
    
    @inlinable
    public static func * (a: DefaultMatrixImpl<R>, r: R) -> Self {
        a.mapNonZeroEntries{ (_, _, a) in a * r }
    }
    
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)
    
    public static func *(a: Self, b: Self) -> Self {
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
    
    public func mapNonZeroEntries(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size) { setEntry in
            nonZeroEntries.forEach { (i, j, a) in
                let b = f(i, j, a)
                if !b.isZero {
                    setEntry(i, j, b)
                }
            }
        }
    }
    
    public struct Index: Hashable {
        public let row, col: Int
        public init(_ row: Int, _ col: Int) {
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
