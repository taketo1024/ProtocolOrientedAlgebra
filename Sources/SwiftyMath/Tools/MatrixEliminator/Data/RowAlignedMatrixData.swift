//
//  RowAlignedMatrixData.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/11/02.
//

final class RowAlignedMatrixData<R: Ring> {
    typealias RowElement = (col: Int, value: R)
    typealias Row = LinkedList<RowElement>
    
    var size: (rows: Int, cols: Int)
    var rows: [Row]
    
    init<n, m>(_ A: Matrix<n, m, R>) {
        self.size = A.size
        self.rows = Self.generateRows(A.size.rows, A.nonZeroComponents)
    }

    func find(_ i: Int, _ j: Int) -> (prev: Row.NodePointer?, hit: Row.NodePointer?) {
        var pItr = rows[i].makePointerIterator()
        var prev: Row.NodePointer? = nil
        
        while let p = pItr.next() {
            let s = p.pointee.element.col
            if s == j {
                return (prev, p)
            } else if j < s {
                return (prev, nil)
            }
            prev = p
        }
        
        return (prev, nil)
    }
    
    @inlinable
    func row(_ i: Int) -> Row {
        rows[i]
    }
    
    var components: AnySequence<MatrixComponent<R>> {
        AnySequence((0 ..< size.rows).lazy.flatMap { i in
            self.row(i).map{ (j, a) in MatrixComponent(i, j, a) }
        })
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
    
    func `as`<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix(size: size) { setEntry in
            for i in (0 ..< size.rows) {
                for (j, a) in row(i) {
                    setEntry(i, j, a)
                }
            }
        }
    }
    
    static func generateRows<S: Sequence>(_ n: Int, _ components: S) -> [Row] where S.Element == MatrixComponent<R> {
        let group = components.group{ c in c.row }
        return (0 ..< n).map { i in
            if let list = group[i] {
                let sorted = list.map{ c in RowElement(c.col, c.value) }.sorted{ $0.col }
                return Row(sorted)
            } else {
                return Row()
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
                toPtr.pointee.insertNext( RowElement(j1, a2) )
                (toPrevPtr, toPtr) = (toPtr, toPtr.pointee.next!)
                
                dw += a2.matrixEliminationWeight
            }
        }
        
        if to.headElement!.value.isZero {
            to.dropHead()
        }
        
        return dw
    }
}

