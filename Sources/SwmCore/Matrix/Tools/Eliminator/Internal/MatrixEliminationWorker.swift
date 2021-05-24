//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class MatrixEliminationWorker<R: Ring> {
    typealias Row = MatrixEliminationData<R>.Row

    private var data: MatrixEliminationData<R>
    private var tracker: Tracker
    
    init(data: MatrixEliminationData<R>) {
        self.data = data
        self.tracker = Tracker(data)
    }
    
    convenience init<S: Sequence>(size: (Int, Int), entries: S) where S.Element == MatrixEntry<R> {
        self.init(data: MatrixEliminationData(size: size, entries: entries))
    }
    
    convenience init<Impl, n, m>(_ A: MatrixIF<Impl, n, m>) where Impl.BaseRing == R {
        self.init(size: A.size, entries: A.nonZeroEntries)
    }
    
    var size: MatrixSize {
        data.size
    }
    
    @inlinable
    func row(_ i: Int) -> Row {
        data.row(i)
    }

    @inlinable
    func rowWeight(_ i: Int) -> Int {
        tracker.rowWeight(i)
    }
    
    var numberOfNonEmptyRows: Int {
        data.rows.count{ !$0.isEmpty }
    }
    
    var entries: AnySequence<MatrixEntry<R>> {
        data.entries
    }
    
    var headEntries: [MatrixEntry<R>] {
        data.rows.enumerated().compactMap { (i, row) in
            row.headElement.flatMap { (j, a) in
                (i, j, a)
            }
        }
    }
    
    func headColEntries(in j: Int) -> [ColEntry<R>] {
        tracker
            .rowIndices(withHeadInCol: j)
            .map{ i in (i, row(i).headElement!.value) }
    }
    
    func colEntries(in j0: Int, aboveRow i0: Int) -> [ColEntry<R>] {
        (0 ..< i0).compactMap { i -> ColEntry<R>? in
            if let a = data.find(i, j0).hit?.pointee.element.value {
                return (i, a)
            } else {
                return nil
            }
        }
    }
    
    func transpose() {
        data.transpose()
        tracker = Tracker(data)
    }
    
    @discardableResult
    func apply(_ s: RowElementaryOperation<R>) -> Self {
        switch s {
        case let .AddRow(i, j, r):
            addRow(at: i, to: j, multipliedBy: r)
        case let .MulRow(i, r):
            multiplyRow(at: i, by: r)
        case let .SwapRows(i, j):
            swapRows(i, j)
        }
        return self
    }

    @discardableResult
    func applyAll<S: Sequence>(_ seq: S) -> Self where S.Element == RowElementaryOperation<R> {
        for s in seq {
            apply(s)
        }
        return self
    }

    func multiplyRow(at i: Int, by r: R) {
        data.multiplyRow(at: i, by: r)
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        let ci = row(i).headElement?.col
        let cj = row(j).headElement?.col
        
        data.swapRows(i, j)
        
        tracker.swap( (i, ci), (j, cj) )
    }
    
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        if row(i1).isEmpty {
            return
        }
        
        let ci2 = row(i2).headElement?.col
        let dw = data.addRow(at: i1, to: i2, multipliedBy: r)
        
        tracker.addRowWeight(dw, to: i2)
        tracker.updateRowHead(i2, ci2, row(i2).headElement?.col)
    }
    
    func batchAddRow(at i1: Int, to rowIndices: [Int], multipliedBy rs: [R]) {
        if row(i1).isEmpty {
            return
        }
        
        let oldCols = rowIndices.map{ i in row(i).headElement?.col }
        let results = data.batchAddRow(at: i1, to: rowIndices, multipliedBy: rs)
        
        for (i, dw) in zip(rowIndices, results) {
            tracker.addRowWeight(dw, to: i)
        }
        for (i, oldCol) in zip(rowIndices, oldCols) {
            tracker.updateRowHead(i, oldCol, row(i).headElement?.col)
        }
    }
    
    func resultAs<Impl, n, m>(_ type: MatrixIF<Impl, n, m>.Type) -> MatrixIF<Impl, n, m> where Impl.BaseRing == R {
        .init(size: size, entries: entries)
    }
    
    private final class Tracker {
        private var rowWeights: [Int]
        private var col2rowHead: [Set<Int>] // [col : { rows having head at col }]

        init(_ data: MatrixEliminationData<R>) {
            self.rowWeights = data.rows.map{ l in
                l.sum{ c in c.value.matrixEliminationWeight }
            }
            
            let m = data.size.cols
            self.col2rowHead = Array(repeating: Set<Int>(), count: m)
            
            for (i, list) in data.rows.enumerated() {
                if let j = list.headElement?.col {
                    col2rowHead[j].insert(i)
                }
            }
        }
        
        func rowWeight(_ i: Int) -> Int {
            rowWeights[i]
        }
        
        func rowIndices(withHeadInCol j: Int) -> Set<Int> {
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
