//
//  MatrixImpl.swift
//  Sample
//
//  Created by Taketo Sano on 2019/10/04.
//

public protocol MatrixImpl {
    associatedtype BaseRing: Ring
    
    init(size: (Int, Int), initializer: ( (Int, Int, BaseRing) -> Void ) -> Void)
    
    subscript(i: Int, j: Int) -> BaseRing { get set }
    var size: (rows: Int, cols: Int) { get }
    var nonZeroComponents: AnySequence<MatrixComponent<BaseRing>> { get }
    
    static func ==(a: Self, b: Self) -> Bool
    static func +(a: Self, b: Self) -> Self
    static func *(a: Self, b: Self) -> Self
}

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
    
    public init(size: (Int, Int), initializer: ( (Int, Int, R) -> Void ) -> Void) {
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
    
    public var nonZeroComponents: AnySequence<(row: Int, col: Int, value: R)> {
        AnySequence( data.lazy.map{ (c, a) -> MatrixComponent<R> in (c.row, c.col, a) } )
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.data == b.data
    }
    
    public static func +(a: Self, b: Self) -> Self {
        assert(a.size == b.size)
        return .init(size: a.size, data: a.data.merging(b.data, uniquingKeysWith: +).exclude{ $0.value.isZero })
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
