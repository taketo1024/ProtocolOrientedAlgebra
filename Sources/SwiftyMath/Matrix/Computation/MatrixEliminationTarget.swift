//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

internal typealias ComputationSpecializedRing = 𝐙

internal final class MatrixEliminationTarget<R: Ring>: Equatable, CustomStringConvertible {
    enum Alignment: String, Codable {
        case horizontal, vertical
    }
    
    typealias Table =  [Int : [(Int, R)]]

    var size: (rows: Int, cols: Int)
    var align: Alignment
    var table: Table
    
    private init(size: (Int, Int), align: Alignment, table: Table) {
        if _isDebugAssertConfiguration() {
            let (rows, cols) = size
            assert(table.values.allSatisfy{ !$0.isEmpty })
            assert(table.values.allSatisfy{ $0.allSatisfy{ $0.1 != .zero }})
            
            switch align {
            case .horizontal:
                assert(table.keys.allSatisfy{ (0 ..< rows).contains($0) })
                assert(table.values.allSatisfy{ $0.allSatisfy{ (0 ..< cols).contains($0.0) } })
                assert(table.values.allSatisfy{ $0.map{ $0.0 } == $0.map{ $0.0 }.unique().sorted() })
            case .vertical:
                assert(table.keys.allSatisfy{ (0 ..< cols).contains($0) })
                assert(table.values.allSatisfy{ $0.allSatisfy{ (0 ..< rows).contains($0.0) } })
                assert(table.values.allSatisfy{ $0.map{ $0.0 } == $0.map{ $0.0 }.unique().sorted() })
            }
        }
        
        self.size = size
        self.align = align
        self.table = table
    }
    
    convenience init<n, m>(matrix: Matrix<n, m, R>, align: Alignment = .horizontal) {
        self.init(size: matrix.size, align: align, table: MatrixEliminationTarget.generateTable(align, matrix))
    }
    
    static func generateTable<S: Sequence>(_ align: Alignment, _ components: S) -> Table where S.Element == MatrixComponent<R> {
        switch align {
        case .horizontal:
            return components.group{ c in c.row }.mapValues{ l in l.sorted{ c in c.col }.map{ c in (c.col, c.value) } }
        case .vertical:
            return components.group{ c in c.col }.mapValues{ l in l.sorted{ c in c.row }.map{ c in (c.row, c.value) } }
        }
    }
    
    subscript(i: Int, j: Int) -> R {
        switch align {
        case .horizontal: return table[i]?.binarySearch(j, { $0.0 } )?.element.1 ?? .zero
        case .vertical: return table[j]?.binarySearch(i, { $0.0 } )?.element.1 ?? .zero
        }
    }
    
    func switchAlignment(_ align: Alignment) {
        if self.align == align {
            return
        }
        
        self.table = MatrixEliminationTarget.generateTable(align, components)
        self.align = align
    }
    
    var isDiagonal: Bool {
        return table.allSatisfy { (i, list) in
            (list.count == 0) || (list.count == 1) && list.first!.0 == i
        }
    }
    
    var components: [MatrixComponent<R>] {
        switch align {
        case .horizontal:
            return table.flatMap{ (i, list) in list.map{(j, a) in (i, j, a)} }
        case .vertical:
            return table.flatMap{ (j, list) in list.map{(i, a) in (i, j, a)} }
        }
    }
    
    func transpose() {
        size = (size.cols, size.rows)
        align = (align == .horizontal) ? .vertical : .horizontal
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    func multiplyRow(at i0: Int, by r: R) {
        switchAlignment(.horizontal)
        
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
        switchAlignment(.horizontal)
        
        let row0 = table[i0]?.map{ (j, a) in (j, r * a) } ?? []
        let row1 = table[i1] ?? []
        
        table[i1] = MatrixEliminationTarget.mergeRows(row0, row1)
    }
    
    func swapRows(_ i0: Int, _ i1: Int) {
        switchAlignment(.horizontal)
        
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
    
    static func identity(size n: Int, align: Alignment) -> MatrixEliminationTarget<R> {
        let components = (0 ..< n).map{ i in (i, i, R.identity)}
        return MatrixEliminationTarget(size: (n, n), align: align, table: MatrixEliminationTarget.generateTable(align, components))
    }
    
    static func ==(a: MatrixEliminationTarget, b: MatrixEliminationTarget) -> Bool {
        if a.size != b.size {
            return false
        }
        func s(_ a: MatrixComponent<R>, _ b: MatrixComponent<R>) -> Bool {
            (a.row < b.row) || (a.row == b.row && a.col < b.col)
        }
        let (z1, z2) = (a.components.sorted(by: s), b.components.sorted(by: s))
        return z1.count == z2.count && zip(z1, z2).allSatisfy{ $0 == $1 }
    }
    
    public var asMatrixData: [MatrixCoord : R] {
        return DMatrix(self).data
    }
    
    var description: String {
        return ""
    }
}

extension Matrix {
    internal init(_ target: MatrixEliminationTarget<R>) {
        self.init(size: target.size, components: target.components)
    }
}

