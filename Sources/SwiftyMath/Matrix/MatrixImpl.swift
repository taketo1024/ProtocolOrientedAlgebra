//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

internal typealias ComputationSpecializedRing = 𝐙

internal final class MatrixImpl<R: Ring>: Hashable, CustomStringConvertible {
    typealias Component = MatrixComponent<R>
    typealias Table =  [Int : [(Int, R)]]
    
    enum Alignment: String, Codable {
        case Rows, Cols
    }
    
    var rows: Int
    var cols: Int
    
    var align: Alignment
    var table: Table
    
    private init(_ rows: Int, _ cols: Int, _ align: Alignment, _ table: Table) {
        if _isDebugAssertConfiguration() {
            assert(table.values.allSatisfy{ !$0.isEmpty })
            assert(table.values.allSatisfy{ $0.allSatisfy{ $0.1 != .zero }})
            
            switch align {
            case .Rows:
                assert(table.keys.allSatisfy{ (0 ..< rows).contains($0) })
                assert(table.values.allSatisfy{ $0.allSatisfy{ (0 ..< cols).contains($0.0) } })
                assert(table.values.allSatisfy{ $0.map{ $0.0 } == $0.map{ $0.0 }.unique().sorted() })
            case .Cols:
                assert(table.keys.allSatisfy{ (0 ..< cols).contains($0) })
                assert(table.values.allSatisfy{ $0.allSatisfy{ (0 ..< rows).contains($0.0) } })
                assert(table.values.allSatisfy{ $0.map{ $0.0 } == $0.map{ $0.0 }.unique().sorted() })
            }
        }
        
        self.rows = rows
        self.cols = cols
        self.align = align
        self.table = table
    }
    
    convenience init(rows: Int, cols: Int, align: Alignment = .Rows, grid: [R]) {
        let components = grid.enumerated().compactMap{ (k, a) -> Component? in
            (a != .zero) ? MatrixComponent(k / cols, k % cols, a) : nil
        }
        self.init(rows: rows, cols: cols, align: align, components: components)
    }
    
    convenience init(rows: Int, cols: Int, align: Alignment = .Rows, generator g: (Int, Int) -> R) {
        let components = (0 ..< rows).flatMap { i -> [Component] in
            (0 ..< cols).compactMap { j -> Component? in
                let a = g(i, j)
                return (a != .zero) ? Component(i, j, a) : nil
            }
        }
        self.init(rows: rows, cols: cols, align: align, components: components)
    }
    
    convenience init<S: Sequence>(rows: Int, cols: Int, align: Alignment = .Rows, components: S) where S.Element == Component {
        self.init(rows, cols, align, MatrixImpl.generateTable(align, components))
    }
    
    static func generateTable<S: Sequence>(_ align: Alignment, _ components: S) -> Table where S.Element == Component {
        let filtered = components.filter{ $0.value != .zero }
        switch align {
        case .Rows:
            return filtered.group{ c in c.row }.mapValues{ l in l.sorted{ c in c.col }.map{ c in (c.col, c.value) } }
        case .Cols:
            return filtered.group{ c in c.col }.mapValues{ l in l.sorted{ c in c.row }.map{ c in (c.row, c.value) } }
        }
    }
    
    subscript(i: Int, j: Int) -> R {
        get {
            switch align {
            case .Rows: return table[i]?.binarySearch(j, { $0.0 } )?.element.1 ?? .zero
            case .Cols: return table[j]?.binarySearch(i, { $0.0 } )?.element.1 ?? .zero
            }
        } set {
            switch align {
            case .Rows:
                let row = MatrixImpl.mergeRows(table[i] ?? [], [(j, newValue - self[i, j])])
                table[i] = row
            case .Cols:
                let col = MatrixImpl.mergeRows(table[j] ?? [], [(i, newValue - self[i, j])])
                table[j] = col
            }
        }
    }
    
    func copy() -> MatrixImpl<R> {
        return MatrixImpl(rows, cols, align, table)
    }
    
    func switchAlignment(_ align: Alignment) {
        if self.align == align {
            return
        }
        
        let comps = components
        
        self.align = align
        self.table = MatrixImpl.generateTable(align, comps)
    }
    
    var isZero: Bool {
        return table.isEmpty
    }
    
    var isDiagonal: Bool {
        return table.allSatisfy { (i, list) in
            (list.count == 0) || (list.count == 1) && list.first!.0 == i
        }
    }
    
    var isIdentity: Bool {
        return rows == cols && table.allSatisfy { (i, list) in
            (list.count == 1) && list.first! == (i, .identity)
        }
    }
    
    static func identity(size n: Int, align: Alignment) -> MatrixImpl<R> {
        let components = (0 ..< n).map{ i in MatrixComponent(i, i, R.identity)}
        return MatrixImpl(rows: n, cols: n, align: align, components: components)
    }
    
    var components: [Component] {
        switch align {
        case .Rows:
            return table.flatMap{ (i, list) in list.map{(j, a) in MatrixComponent(i, j, a)} }
        case .Cols:
            return table.flatMap{ (j, list) in list.map{(i, a) in MatrixComponent(i, j, a)} }
        }
    }
    
    var grid: [R] {
        var grid = Array(repeating: R.zero, count: rows * cols)
        for c in components {
            grid[c.row * cols + c.col] = c.value
        }
        return grid
    }
    
    @discardableResult
    func transpose() -> MatrixImpl<R> {
        (rows, cols) = (cols, rows)
        align = (align == .Rows) ? .Cols : .Rows
        return self
    }
    
    var trace: R {
        assert(rows == cols)
        return table.compactMap { (i, list) -> R? in
            list.first{ $0.0 == i }.map{ $0.1 }
        }.sumAll()
    }
    
    var determinant: R {
        assert(rows == cols)
        if rows == 0 {
            return .identity
        }
        
        guard let row = table[0] else {
            return .zero
        }
        
        return row.sum{ (j, a) in
            let minor = (align == .Rows)
                ? submatrix({ $0 != 0 }, { $0 != j })
                : submatrix({ $0 != j }, { $0 != 0 })
            return R(from: (-1).pow(j)) * a * minor.determinant
        }
    }
    
    func cofactor(_ i: Int, _ j: Int) -> R {
        assert(rows == cols)
        let ε = R(from: (-1).pow(i + j))
        let d = submatrix({ $0 != i }, { $0 != j }).determinant
        return ε * d
    }
    
    var inverse: MatrixImpl<R>? {
        assert(rows == cols)
        
        guard let dInv = determinant.inverse else {
            return nil
        }
        return dInv * MatrixImpl(rows: rows, cols: cols) { (i, j) in self.cofactor(j, i) }
    }
    
    func mapComponents<R2>(_ f: (R) -> R2) -> MatrixImpl<R2> {
        typealias M = MatrixImpl<R2>
        let mapped = table.mapValues { list in
            list.map { (i, r) in (i, f(r)) }
                .exclude { (_, r) in r == .zero }
            }.exclude{ (_, list) in list.isEmpty }
        let a = (align == .Rows) ? M.Alignment.Rows : M.Alignment.Cols
        return M(rows, cols, a, mapped)
    }
    
    func submatrix(rowRange: CountableRange<Int>) -> MatrixImpl<R> {
        return submatrix(rowRange, 0 ..< cols)
    }
    
    func submatrix(colRange: CountableRange<Int>) -> MatrixImpl<R> {
        return submatrix(0 ..< rows, colRange)
    }
    
    func submatrix(_ rowRange: CountableRange<Int>, _ colRange: CountableRange<Int>) -> MatrixImpl<R> {
        assert(0 <= rowRange.lowerBound && rowRange.upperBound <= rows)
        assert(0 <= colRange.lowerBound && colRange.upperBound <= cols)

        return submatrix({i in rowRange.contains(i)}, {j in colRange.contains(j)})
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    func submatrix(_ rowCond: (Int) -> Bool, _ colCond: (Int) -> Bool) -> MatrixImpl<R> {
        let (sRows, sCols, iList, jList): (Int, Int, [Int], [Int])
        
        switch align {
        case .Rows:
            (iList, jList) = ((0 ..< rows).filter(rowCond), (0 ..< cols).filter(colCond))
            (sRows, sCols) = (iList.count, jList.count)
        case .Cols:
            (iList, jList) = ((0 ..< cols).filter(colCond), (0 ..< rows).filter(rowCond))
            (sRows, sCols) = (jList.count, iList.count)
        }
        
        let subTable = table.compactMap{ (i, list) -> (Int, [(Int, R)])? in
            guard let i1 = iList.binarySearch(i) else {
                return nil
            }
            let subList = list.compactMap{ (j, a) -> (Int, R)? in
                guard let j1 = jList.binarySearch(j) else {
                    return nil
                }
                return (j1, a)
            }
            return !subList.isEmpty ? (i1, subList) : nil
        }
        
        return MatrixImpl(sRows, sCols, align, Dictionary(pairs: subTable))
    }
    
    func concatDiagonally(_ B: MatrixImpl<R>) -> MatrixImpl<R> {
        let A = self
        A.switchAlignment(.Rows)
        B.switchAlignment(.Rows)
        
        let table = A.table + B.table.mapPairs{ (i, list) in (i + A.rows, list.map{ (j, r) in (j + A.cols, r) })}
        return MatrixImpl<R>(A.rows + B.rows, A.cols + B.cols, .Rows, table)
    }
    
    func concatHorizontally(_ B: MatrixImpl<R>) -> MatrixImpl<R> {
        let A = self
        assert(A.rows == B.rows)
        
        A.switchAlignment(.Cols)
        B.switchAlignment(.Cols)
        
        let table = A.table + B.table.mapKeys{ j in j + A.cols }
        return MatrixImpl(A.rows, A.cols + B.cols, .Cols, table)
    }
    
    func concatVertically(_ B: MatrixImpl<R>) -> MatrixImpl<R> {
        let A = self
        assert(A.cols == B.cols)
        
        A.switchAlignment(.Rows)
        B.switchAlignment(.Rows)
        
        let table = A.table + B.table.mapKeys{ i in i + A.rows }
        return MatrixImpl(A.rows + B.rows, A.cols, .Rows, table)
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static func ==(a: MatrixImpl, b: MatrixImpl) -> Bool {
        if (a.rows, a.cols) != (b.rows, b.cols) {
            return false
        }
        let (z1, z2) = (a.components, b.components)
        return z1.count == z2.count && z1.allSatisfy{ (i, j, x) in b[i, j] == x }
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static func +(a: MatrixImpl, b: MatrixImpl) -> MatrixImpl<R> {
        assert( (a.rows, a.cols) == (b.rows, b.cols) )
        
        b.switchAlignment(a.align)
        
        let iList = Set(a.table.keys).union(b.table.keys)
        let table = iList.compactMap { i in
            MatrixImpl.mergeRows(a.table[i] ?? [], b.table[i] ?? []).map{ (i, $0) }
        }
        
        return MatrixImpl(a.rows, a.cols, a.align, Dictionary(pairs: table))
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static prefix func -(a: MatrixImpl) -> MatrixImpl<R> {
        return a.mapComponents{ -$0 }
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static func *(r: R, a: MatrixImpl) -> MatrixImpl<R> {
        return a.mapComponents{ r * $0 }
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static func *(a: MatrixImpl, r: R) -> MatrixImpl<R> {
        return a.mapComponents{ $0 * r }
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    static func *(a: MatrixImpl, b: MatrixImpl) -> MatrixImpl<R> {
        assert(a.cols == b.rows)
        
        // TODO support .Cols
        
        a.switchAlignment(.Rows)
        b.switchAlignment(.Rows)
        
        let table = a.table.compactMap { (i, list1) -> (Int, [(Int, R)])? in
            
            //       k              j
            //       v            | v        |
            //  i>|  x    *  |  k>| y   *    |
            //                    |          |
            //                    | * *    * |
            //                    |          |
            //
            //                         ↓
            //
            //                  i>| * * *  * |
            
            var tmp: [Int: R] = [:]
            
            for (k, x) in list1 where b.table[k] != nil {
                let list2 = b.table[k]!
                for (j, y) in list2 {
                    tmp[j] = (tmp[j] ?? .zero) + x * y
                }
            }
            
            let row = tmp.filter{ $0.value != .zero }.map{ ($0.key, $0.value ) }.sorted{ $0.0 }
            return !row.isEmpty ? (i, row) : nil
        }
        
        return MatrixImpl(a.rows, b.cols, a.align, Dictionary(pairs: table))
    }

    @_specialize(where R == ComputationSpecializedRing)
    func multiplyRow(at i0: Int, by r: R) {
        switchAlignment(.Rows)
        
        guard var row = table[i0] else {
            return
        }
        
        let n = row.count
        var p = UnsafeMutablePointer(&row)
        
        for _ in 0 ..< n {
            let (j, a) = p.pointee
            p.pointee = (j, r * a)
            p += 1
        }
        
        row = row.filter{ $0.1 != .zero }
        table[i0] = !row.isEmpty ? row : nil
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    func addRow(at i0: Int, to i1: Int, multipliedBy r: R = .identity) {
        switchAlignment(.Rows)
        
        let row0 = table[i0]?.map{ (j, a) in (j, r * a) } ?? []
        let row1 = table[i1] ?? []
        
        table[i1] = MatrixImpl.mergeRows(row0, row1)
    }
    
    func swapRows(_ i0: Int, _ i1: Int) {
        switchAlignment(.Rows)
        
        let r0 = table[i0]
        table[i0] = table[i1]
        table[i1] = r0
    }
    
    func multiplyCol(at j0: Int, by r: R) {
        transpose()
        multiplyRow(at: j0, by: r)
        transpose()
    }
    
    func addCol(at j0: Int, to j1: Int, multipliedBy r: R = .identity) {
        transpose()
        addRow(at: j0, to: j1, multipliedBy: r)
        transpose()
    }
    
    func swapCols(_ j0: Int, _ j1: Int) {
        transpose()
        swapRows(j0, j1)
        transpose()
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    private static func mergeRows(_ row0: [(Int, R)], _ row1: [(Int, R)]) -> [(Int, R)]? {
        switch (row0.isEmpty, row1.isEmpty) {
        case (true,  true): return nil
        case (false, true): return row0
        case (true, false): return row1
        default: ()
        }
        
        var result: [(Int, R)] = []
        
        let (n0, n1) = (row0.count, row1.count)
        var (p0, p1) = (UnsafePointer(row0), UnsafePointer(row1))
        var (k0, k1) = (0, 0) // counters
        
        while k0 < n0 && k1 < n1 {
            let (j0, a0) = p0.pointee
            let (j1, a1) = p1.pointee
            
            if j0 == j1 {
                result.append((j0, a0 + a1))
                
                p0 += 1
                p1 += 1
                k0 += 1
                k1 += 1
                
            } else if j0 < j1 {
                result.append((j0, a0))
                
                p0 += 1
                k0 += 1
                
            } else if j0 > j1 {
                result.append( (j1, a1) )
                
                p1 += 1
                k1 += 1
            }
        }
        
        for _ in k0 ..< n0 {
            let (j0, a0) = p0.pointee
            result.append((j0, a0))
            
            p0 += 1
            k0 += 1
        }
        
        for _ in k1 ..< n1 {
            let (j1, a1) = p1.pointee
            result.append((j1, a1))
            
            p1 += 1
            k1 += 1
        }
        
        result = result.filter{ $0.1 != .zero }
        return !result.isEmpty ? result : nil
    }
    
    var hashValue: Int {
        return isZero ? 0 : 1 // TODO
    }
    
    var description: String {
        return "CMatrix<\(rows), \(cols)> [ " + table.flatMap { (i, list) in
            list.map{ (j, a) in "\(a)" + Format.sub("\(align == .Rows ? (i, j) : (j, i) )") }
        }.joined(separator: ", ") + " ]"
    }
}

extension MatrixImpl: Codable where R: Codable {
    enum CodingKeys: String, CodingKey {
        case rows, cols, grid
    }
    
    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let rows = try c.decode(Int.self, forKey: .rows)
        let cols = try c.decode(Int.self, forKey: .cols)
        let grid = try c.decode([R].self, forKey: .grid)
        self.init(rows: rows, cols: cols, align: .Rows, grid: grid)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(rows, forKey: .rows)
        try c.encode(cols, forKey: .cols)
        try c.encode(grid, forKey: .grid)
    }
}
