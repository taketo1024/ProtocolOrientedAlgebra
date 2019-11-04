//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

final class RowEliminationData<R: Ring> {
    typealias Row = RowAlignedMatrixData<R>.Row

    private var data: RowAlignedMatrixData<R>
    private var tracker: Tracker
    
    init(data: RowAlignedMatrixData<R>) {
        self.data = data
        self.tracker = Tracker(data)
    }
    
    convenience init<n, m>(_ A: Matrix<n, m, R>) {
        self.init(data: RowAlignedMatrixData(A))
    }
    
    var size: (Int, Int) {
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
    
    func headElements(inCol j: Int) -> [ColComponent<R>] {
        tracker.rows(inCol: j).map{ i in (i, row(i).headElement!.value) }
    }
    
    func elements(inCol j0: Int, aboveRow i0: Int) -> [ColComponent<R>] {
        (0 ..< i0).compactMap { i -> ColComponent<R>? in
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
    
    var components: AnySequence<MatrixComponent<R>> {
        data.components
    }
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        data.as(type)
    }
    
    private final class Tracker {
        private var rowWeights: [Int]
        private var col2rowHead: [Set<Int>] // [col : { rows having head at col }]

        init(_ data: RowAlignedMatrixData<R>) {
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
