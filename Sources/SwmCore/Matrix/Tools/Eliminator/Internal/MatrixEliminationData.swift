//
//  RowAlignedMatrixData.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/11/02.
//

internal final class MatrixEliminationData<R: Ring> {
    typealias Row = LinkedList<RowEntry<R>>
    
    var size: MatrixSize
    private(set) var rows: [Row]
    
    private init(size: MatrixSize, rows: [Row]) {
        self.size = size
        self.rows = rows
    }
    
    convenience init<S: Sequence>(size: (rows: Int, cols: Int), entries: S) where S.Element == MatrixEntry<R> {
        self.init(size: size, rows: Self.generateRows(rows: size.rows, entries: entries))
    }
    
    var entries: AnySequence<MatrixEntry<R>> {
        AnySequence(rows.enumerated().lazy.flatMap { (i, row) in
            row.lazy.map { (j, a) in (i, j, a) }
        })
    }
    
    @inlinable
    func row(_ i: Int) -> Row {
        rows[i]
    }
    
    func find(_ i: Int, _ j: Int) -> (hit: Row.NodePointer?, prev: Row.NodePointer?) {
        rows[i].find({ e in e.col == j}, while: { e in e.col <= j})
    }
    
    func transpose() {
        let tSize = (size.cols, size.rows)
        let tRows = Self.generateRows(
            rows: size.cols,
            entries: entries.map { (i, j, a) in (j, i, a) }
        )
        
        self.size = tSize
        self.rows = tRows
    }
    
    @discardableResult
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) -> Int {
        if !row(i1).isEmpty {
            return addRow(row(i1), into: row(i2), multipliedBy: r)
        } else {
            return 0
        }
    }
    
    @discardableResult
    func batchAddRow(at i1: Int, to rowIndices: [Int], multipliedBy rs: [R]) -> [Int] {
        let from = row(i1)
        if !from.isEmpty {
            return Array(zip(rowIndices, rs)).parallelMap { (i2, r) in
                addRow(from, into: row(i2), multipliedBy: r)
            }
        } else {
            return [0] * rowIndices.count
        }
    }
    
    @discardableResult
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)
    
    private func addRow(_ from: Row, into to: Row, multipliedBy r: R) -> Int {
        if from.isEmpty {
            return 0
        }

        var dw = 0
        
        let fromHeadCol = from.headElement!.col
        if to.isEmpty || fromHeadCol < to.headElement!.col {
            
            // from: ●-->○-->○----->○-------->
            //   to:            ●------->○--->
            //
            //   ↓
            //
            // from: ●-->○-->○----->○-------->
            //   to: ●--------->○------->○--->
            
            to.insertHead( (fromHeadCol, .zero) )
        }
        
        var fromItr = from.makeIterator()
        var toPtr = to.headPointer!
        var toPrevPtr = toPtr
        
        while let (j1, a1) = fromItr.next() {
            // At this point, it is assured that
            // `from.value.col >= to.value.col`
            
            // from: ------------->●--->○-------->
            //   to: -->●----->○------------>○--->
            
            while let next = toPtr.pointee.next, next.pointee.element.col <= j1 {
                (toPrevPtr, toPtr) = (toPtr, next)
            }
            
            let (j2, a2) = toPtr.pointee.element
            
            // from: ------------->●--->○-------->
            //   to: -->○----->●------------>○--->

            if j1 == j2 {
                let b2 = a2 + r * a1
                
                if b2.isZero && toPtr != toPrevPtr {
                    toPtr = toPrevPtr
                    toPtr.pointee.dropNext()
                } else {
                    toPtr.pointee.element.value = b2
                }
                
                dw += b2.matrixEliminationWeight - a2.matrixEliminationWeight
                
            } else {
                let a2 = r * a1
                toPtr.pointee.insertNext( RowEntry(j1, a2) )
                (toPrevPtr, toPtr) = (toPtr, toPtr.pointee.next!)
                
                dw += a2.matrixEliminationWeight
            }
        }
        
        if to.headElement!.value.isZero {
            to.dropHead()
        }
        
        return dw
    }
    
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)

    func multiplyRow(at i: Int, by r: R) {
        row(i).modifyEach { e in
            e.value = r * e.value
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        rows.swapAt(i, j)
    }
    
    private static func generateRows<S: Sequence>(rows n: Int, entries: S) -> [Row] where S.Element == MatrixEntry<R> {
        let group = entries.group{ c in c.row }
        return (0 ..< n).map { i in
            if let list = group[i] {
                let sorted = list.map{ c in RowEntry(c.col, c.value) }.sorted{ $0.col }
                return Row(sorted)
            } else {
                return Row()
            }
        }
    }
}

