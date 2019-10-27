//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

final class RowEliminationWorker<R: Ring> {
    typealias RowElement = (col: Int, value: R)
    typealias Row = LinkedList<RowElement>
    
    var size: (rows: Int, cols: Int)
    private var rows: [Row]
    private var tracker: Tracker?
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        
        let group = components.group{ c in c.row }
        self.rows = (0 ..< size.0).map { i in
            if let list = group[i] {
                let sorted = list.map{ c in RowElement(c.col, c.value) }.sorted{ $0.col }
                return Row(sorted)
            } else {
                return Row()
            }
        }
        self.tracker = trackRowInfos ? Tracker(size, rows) : nil
    }
    
    convenience init<n, m>(_ A: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: A.size, components: A.nonZeroComponents, trackRowInfos: trackRowInfos)
    }
    
    @inlinable
    func row(_ i: Int) -> Row {
        rows[i]
    }
    
    @inlinable
    func rowWeight(_ i: Int) -> Int {
        tracker?.rowWeight(i) ?? 0
    }
    
    var components: [MatrixComponent<R>] {
        (0 ..< size.rows).flatMap { i in
            rows[i].map{ (j, a) in (i, j, a) }
        }
    }
    
    func components(inCol j0: Int, withinRows rowRange: CountableRange<Int>) -> [MatrixComponent<R>] {
        rowRange.compactMap { i -> MatrixComponent<R>? in
            for (j, a) in rows[i] {
                if j == j0 {
                    return (i, j, a)
                } else if j > j0 {
                    return nil
                }
            }
            return nil
        }
    }
    
    func headComponent(ofRow i: Int) -> MatrixComponent<R>? {
        rows[i].headElement.map{ e in (i, e.col, e.value) }
    }
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        tracker?.rows(inCol: j).map{ i in (i, j, rows[i].headElement!.value) } ?? []
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
    func multiplyRow(at i: Int, by r: R) {
        rows[i].modifyEach { e in
            e.value = r * e.value
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        tracker?.swap(
            (i, headComponent(ofRow: i)?.col),
            (j, headComponent(ofRow: j)?.col)
        )
        rows.swapAt(i, j)
    }
    
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        let (from, to) = (rows[i1], rows[i2])
        if from.isEmpty {
            return
        }
        
        let oldToCol = to.headElement?.col
        let dw = addRow(from, to, r)
        
        tracker?.addRowWeight(dw, to: i2)
        tracker?.updateRowHead(i2, oldToCol, rows[i2].headElement?.col)
    }
    
    func batchAddRow(at i1: Int, to rowIndices: [Int], multipliedBy rs: [R]) {
        let from = rows[i1]
        if from.isEmpty {
            return
        }
        
        let oldCols = rowIndices.map{ i in rows[i].headElement?.col }
        let results = zip(rowIndices, rs)
            .map{ (i, r) in (rows[i], r) }
            .parallelMap { (to, r) in addRow(from, to, r) }
        
        for (i, dw) in zip(rowIndices, results) {
            tracker?.addRowWeight(dw, to: i)
        }
        
        for (i, oldCol) in zip(rowIndices, oldCols) {
            tracker?.updateRowHead(i, oldCol, rows[i].headElement?.col)
        }
    }
    
    @_specialize(where R == 𝐙)
    private func addRow(_ from: Row, _ to: Row, _ r: R) -> Int {
        if from.isEmpty {
            return 0
        }

        var dw = 0
        let track = (tracker != nil)
        
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
                
                if track {
                    dw += b2.matrixEliminationWeight - a2.matrixEliminationWeight
                }
                
            } else {
                let a2 = r * a1
                toPtr.pointee.insertNext( RowElement(j1, a2) )
                (toPrevPtr, toPtr) = (toPtr, toPtr.pointee.next!)
                
                if track {
                    dw += a2.matrixEliminationWeight
                }
            }
        }
        
        if to.headElement!.value.isZero {
            to.dropHead()
        }
        
        return dw
    }
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix(size: size) { setEntry in
            for i in (0 ..< size.rows) {
                for (j, a) in rows[i] {
                    setEntry(i, j, a)
                }
            }
        }
    }
        
    private final class Tracker {
        private var rowWeights: [Int]
        private var col2rowHead: [Set<Int>] // [col : { rows having head at col }]

        init(_ size: (Int, Int), _ rows: [Row]) {
            self.rowWeights = rows
                .map{ l in l.sum{ c in c.value.matrixEliminationWeight } }
            
            self.col2rowHead = Array(repeating: Set<Int>(), count: size.1)
            
            for (i, list) in rows.enumerated() {
                if let j = list.headElement?.col {
                    col2rowHead[j].insert(i)
                }
            }
        }
        
        func rowWeight(_ i: Int) -> Int {
            rowWeights[i]
        }
        
        func rows(inCol j: Int) -> Set<Int> {
            col2rowHead[j]
        }
        
        func swap(_ e1: (Int, Int?), _ e2: (Int, Int?)) {
            let (i1, j1) = e1
            let (i2, j2) = e2
            
            rowWeights.swapAt(i1, i2)
            
            if j1 != j2 {
                if let j1 = j1 {
                    col2rowHead[j1].remove(i1)
                    col2rowHead[j1].insert(i2)
                }
                
                if let j2 = j2 {
                    col2rowHead[j2].remove(i2)
                    col2rowHead[j2].insert(i1)
                }
            }
        }
        
        func addRowWeight(_ dw: Int, to i: Int) {
            rowWeights[i] += dw
        }
        
        func updateRowHead(_ i: Int, _ j0: Int?, _ j1: Int?) {
            if j0 == j1 { return }
            
            if let j0 = j0 {
                col2rowHead[j0].remove(i)
            }
            if let j1 = j1 {
                col2rowHead[j1].insert(i)
            }
        }
    }
}
