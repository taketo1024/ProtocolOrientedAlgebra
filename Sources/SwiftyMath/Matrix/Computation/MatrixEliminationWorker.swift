//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

internal final class RowEliminationWorker<R: EuclideanRing>: Equatable {
    var size: (rows: Int, cols: Int)
    
    typealias Table = [Int : LinkedList<(col: Int, value: R)>]
    private var working: Table
    private var result : Table
    
    private var trackRowInfos: Bool
    private var headPositions: [Int : Set<Int>] // [col : { rows having head at col }]
    private var rowWeights: [Int : Int]
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        self.working = components.group{ c in c.row }
            .mapValues { l in
                let sorted = l.sorted{ c in c.col }.map{ c in (c.col, c.value) }
                return LinkedList.generate(from: sorted)!
        }
        self.result = [:]
        result.reserveCapacity(working.count)
        
        self.trackRowInfos = trackRowInfos
        if trackRowInfos {
            self.headPositions = working
                .map{ (i, head) in (i, head.value.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
            self.rowWeights = working.mapValues{ l in l.sum{ c in c.value.value.eucDegree } }
            
        } else {
            self.headPositions = [:]
            self.rowWeights = [:]
        }
    }
    
    convenience init<n, m>(from matrix: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: matrix.size, components: matrix, trackRowInfos: trackRowInfos)
    }
    
    func headElement(_ i: Int) -> (col: Int, value: R)? {
        return working[i]?.value
    }
    
    @_specialize(where R == 𝐙)
    func headElements(ofCol j: Int) -> [(row: Int, value: R)] {
        assert(trackRowInfos)
        return headPositions[j]?.map { i in (i, working[i]!.value.value) } ?? []
    }
    
    @_specialize(where R == 𝐙)
    func weight(ofRow i: Int) -> Int {
        assert(trackRowInfos)
        return rowWeights[i] ?? 0
    }
    
    func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        switch s {
        case let .AddRow(i, j, r):
            addRow(at: i, to: j, multipliedBy: r)
        case let .MulRow(i, r):
            multiplyRow(at: i, by: r)
        case let .SwapRows(i, j):
            swapRows(i, j)
        default:
            fatalError()
        }
    }

    @_specialize(where R == 𝐙)
    func multiplyRow(at i: Int, by r: R) {
        assert(r != .zero)
        guard let row = working[i] else {
            return
        }
        for t in row {
            t.value.value = r * t.value.value
        }
        
        if trackRowInfos {
            updateRowWeight(i)
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        if trackRowInfos {
            removeHeadPosition(i)
            removeHeadPosition(j)
        }

        (working[i], working[j]) = (working[j], working[i])
        
        if trackRowInfos {
            updateHeadPosition(i)
            updateHeadPosition(j)
            (rowWeights[i], rowWeights[j]) = (rowWeights[j], rowWeights[i])
        }
    }
    
    @_specialize(where R == 𝐙)
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = working[i1] else {
            return
        }
        
        let toHead = {() -> LinkedList<(col: Int, value: R)> in
            var toHead = working[i2] // possibly nil
            if toHead == nil || fromHead.value.col < toHead!.value.col {
                
                // from: ●-->○-->○----->○-------->
                //   to:            ●------->○--->
                
                return LinkedList((fromHead.value.col, .zero), next: toHead)
                
                // from: ●-->○-->○----->○-------->
                //   to: ●--------->○------->○--->
                
            } else {
                return toHead!
            }
        }()
        
        var (from, to) = (fromHead, toHead)
        
        while true {
            // At this point, it is assured that
            // `from.value.col >= to.value.col`
            
            // from: ------------->●--->○-------->
            //   to: -->●----->○------------>○--->
            
            while let next = to.next, next.value.col <= from.value.col {
                to = next
            }
            
            // from: ------------->●--->○-------->
            //   to: -->○----->●------------>○--->

            if from.value.col == to.value.col {
                to.value.value = to.value.value + r * from.value.value
            } else {
                let c = LinkedList((col: from.value.col, value: r * from.value.value))
                to.insert(c)
                to = c
            }
            
            // from: ------------->●--->○-------->
            //   to: -->○----->○-->●-------->○--->

            if let next = from.next {
                from = next
                
                // from: ------------->○--->●-------->
                //   to: -->○----->○---●-------->○--->
                
            } else {
                break
            }
        }
        
        let result = toHead.drop{ c in c.value == .zero } // possibly nil
        
        if trackRowInfos {
            removeHeadPosition(i2)
        }

        working[i2] = result
        
        if trackRowInfos {
            updateHeadPosition(i2)
            updateRowWeight(i2)
        }
    }
    
    func finished(row i: Int) {
        result[i] = working[i]
        working[i] = nil
    }
    
    var isAllDone: Bool {
        return working.isEmpty
    }
    
    var resultData: MatrixData<R> {
        return Dictionary(pairs: (result + working).flatMap{ (i, list) -> [(MatrixCoord, R)] in
            list.map{ c in
                let (j, a) = c.value
                return (MatrixCoord(i, j), a)
            }
        })
    }
    
    func redo() {
        working = result
        result = [:]
        result.reserveCapacity(working.count)
    }
    
    private func removeHeadPosition(_ i: Int) {
        guard let j = working[i]?.value.col else { return }
        if headPositions[j]!.count == 1 {
            headPositions[j] = nil
        } else {
            headPositions[j]!.remove(i)
        }
    }
    
    private func updateHeadPosition(_ i: Int) {
        guard let j = working[i]?.value.col else { return }
        if headPositions[j] == nil {
            headPositions[j] = [i]
        } else {
            headPositions[j]!.insert(i)
        }
    }
    
    private func updateRowWeight(_ i: Int) {
        if let head = working[i] {
            rowWeights[i] = head.sum{ c in c.value.value.eucDegree }
        } else {
            rowWeights[i] = nil
        }
    }
    
    static func identity(size n: Int) -> RowEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return RowEliminationWorker(size: (n, n), components: comps)
    }

    // for test
    static func ==(a: RowEliminationWorker, b: RowEliminationWorker) -> Bool {
        return (a.working.keys == b.working.keys) && a.working.keys.allSatisfy{ i in
            var itr1 = a.working[i]!.makeIterator()
            var itr2 = b.working[i]!.makeIterator()
            
            while let c1 = itr1.next(), let c2 = itr2.next() {
                if c1.value != c2.value {
                    return false
                }
            }
            return itr1.next() == nil && itr2.next() == nil
        }
    }
}

internal final class ColEliminationWorker<R: EuclideanRing>: Equatable {
    private let rowWorker: RowEliminationWorker<R>
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        rowWorker = RowEliminationWorker(size: (size.1, size.0), components: components.map{(i, j, a) in (j, i, a)})
    }
    
    convenience init<n, m>(from matrix: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: matrix.size, components: matrix)
    }
    
    func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        switch s {
        case .AddCol, .MulCol, .SwapCols:
            rowWorker.apply(s.transposed)
        default:
            fatalError()
        }
    }
    
    var resultData: MatrixData<R> {
        return rowWorker.resultData.mapKeys{ $0.transposed }
    }
    
    static func identity(size n: Int) -> ColEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return ColEliminationWorker(size: (n, n), components: comps)
    }
    
    // for test
    static func ==(a: ColEliminationWorker, b: ColEliminationWorker) -> Bool {
        return a.rowWorker == b.rowWorker
    }
}
