//
//  DefaultMatrixImpl.swift
//  
//
//  Created by Taketo Sano on 2021/05/14.
//

//  DOK (dictionary of keys) implementation.
//  https://en.wikipedia.org/wiki/Sparse_matrix#Dictionary_of_keys_(DOK)
//  Not intended for fast computation.

public struct DefaultMatrixImpl<R: Ring>: MatrixImpl {
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
    
    public var isZero: Bool {
        data.isEmpty
    }
    
    @inlinable
    public var numberOfNonZeros: Int {
        data.count
    }
    
    @inlinable
    public var nonZeroEntries: AnySequence<MatrixEntry<R>> {
        AnySequence(NonZeroEntryIterator(data))
    }
    
    public func mapNonZeroEntries(_ f: (Int, Int, R) -> R) -> Self {
        .init(size: size, data: Dictionary(data.compactMap{ (e, a) in
            let b = f(e.row, e.col, a)
            return b.isZero ? nil : (e, b)
        }))
    }
    
    @inlinable
    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
    }
    
    public static func *(a: Self, b: Self) -> Self {
        assert(a.size.cols == b.size.rows)
        let aCols = a.nonZeroEntries.group(by: { e in e.col })
        let data = Dictionary( b.nonZeroEntries.flatMap{ (j, k, b_jk) in
            (aCols[j] ?? []).map { (i, _, a_ij) in
                (Index(i, k), a_ij * b_jk)
            }
        }, uniquingKeysWith: +)
        
        return .init(
            size: (a.size.rows, b.size.cols),
            data: data.exclude{ $0.value.isZero }
        )
    }
    
    public struct Index: Hashable {
        public let row, col: Int
        public init(_ row: Int, _ col: Int) {
            self.row = row
            self.col = col
        }
    }
    
    public struct NonZeroEntryIterator: Sequence, IteratorProtocol {
        public typealias Element = MatrixEntry<R>
        
        private var itr: Data.Iterator
        public init(_ data: Data) {
            self.itr = data.makeIterator()
        }
        
        public mutating func next() -> MatrixEntry<R>? {
            if let (idx, a) = itr.next() {
                return (idx.row, idx.col, a)
            } else {
                return nil
            }
        }
    }
}
