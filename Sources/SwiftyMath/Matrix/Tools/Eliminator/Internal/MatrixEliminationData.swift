//
//  RowAlignedMatrixData.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/11/02.
//

internal typealias RowEntry<R> = (col: Int, value: R)
internal typealias ColEntry<R> = (row: Int, value: R)

internal final class MatrixEliminationData<R: Ring> {
    typealias Row = LinkedList<RowEntry<R>>
    
    var size: (rows: Int, cols: Int)
    var rows: [Row]
    
    init(size: (rows: Int, cols: Int), rows: [Row]) {
        self.size = size
        self.rows = rows
    }
    
    convenience init<S: Sequence>(size: (rows: Int, cols: Int), components: S) where S.Element == MatrixEntry<R> {
        self.init(size: size, rows: Self.generateRows(size.rows, components))
    }
    
    convenience init<Impl, n, m>(_ A: MatrixIF<Impl, n, m>) where Impl: SparseMatrixImpl, Impl.BaseRing == R {
        self.init(size: A.size, components: A.nonZeroComponents)
    }

    func find(_ i: Int, _ j: Int) -> (hit: Row.NodePointer?, prev: Row.NodePointer?) {
        rows[i].find({ e in e.col == j}, while: { e in e.col <= j})
    }
    
    @inlinable
    func row(_ i: Int) -> Row {
        rows[i]
    }
    
    func sub(_ rowRange: Range<Int>) -> MatrixEliminationData<R> {
        .init(
            size: (rowRange.upperBound - rowRange.lowerBound, size.cols),
            rows: Array(rows[rowRange.lowerBound ..< rowRange.upperBound])
        )
    }
    
    func append(_ row: Row) {
        size = (size.rows + 1, size.cols)
        rows.append(row)
    }
    
    func concat(_ data: MatrixEliminationData<R>) {
        assert(size.cols == data.size.cols)
        size = (size.rows + data.size.rows, size.cols)
        rows.append(contentsOf: data.rows)
    }
    
    func transpose() {
        let tSize = (size.cols, size.rows)
        let tRows = Self.generateRows(size.cols, components.map { (i, j, a) in (j, i, a) })
        
        self.size = tSize
        self.rows = tRows
    }
    
    func apply(_ s: RowElementaryOperation<R>) {
        switch s {
        case let .AddRow(i, j, r):
            addRow(at: i, to: j, multipliedBy: r)
        case let .MulRow(i, r):
            multiplyRow(at: i, by: r)
        case let .SwapRows(i, j):
            swapRows(i, j)
        }
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
    
    @discardableResult
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) -> Int {
        if !row(i1).isEmpty {
            return Self.addRow(row(i1), into: row(i2), multipliedBy: r)
        } else {
            return 0
        }
    }
    
    @discardableResult
    func batchAddRow(at i1: Int, to rowIndices: [Int], multipliedBy rs: [R]) -> [Int] {
        if !row(i1).isEmpty {
            return Array(zip(rowIndices, rs)).parallelMap { (i2, r) in
                Self.addRow(row(i1), into: row(i2), multipliedBy: r)
            }
        } else {
            return [0] * rowIndices.count
        }
    }
    
    var components: AnySequence<MatrixEntry<R>> {
        AnySequence((0 ..< size.rows).lazy.flatMap { i in
            self.row(i).map{ (j, a) in (i, j, a) }
        })
    }
    
    func `as`<Impl, n, m>(_ type: MatrixIF<Impl, n, m>.Type) -> MatrixIF<Impl, n, m> where Impl.BaseRing == R {
        .init(size: size) { setEntry in
            for i in (0 ..< self.size.rows) {
                for (j, a) in self.row(i) {
                    setEntry(i, j, a)
                }
            }
        }
    }
    
    @discardableResult
    @_specialize(where R == 𝐙)
    @_specialize(where R == 𝐐)
    @_specialize(where R == 𝐅₂)

    static func addRow(_ from: Row, into to: Row, multipliedBy r: R) -> Int {
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
    
    private static func generateRows<S: Sequence>(_ n: Int, _ components: S) -> [Row] where S.Element == MatrixEntry<R> {
        let group = components.group{ c in c.row }
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

