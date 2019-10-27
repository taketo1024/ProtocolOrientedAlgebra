//
//  MatrixPivotFinder.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/26.
//

//  Implementation based on:
//
//  "Parallel Sparse PLUQ Factorization modulo p", Charles Bouillaguet, Claire Delaplace, Marie-Emilie Voge.
//  https://hal.inria.fr/hal-01646133/document
//
//  see also:
//
//  SpaSM (Sparse direct Solver Modulo p)
//  https://github.com/cbouilla/spasm

import Dispatch

public final class MatrixPivotFinder<R: Ring> {
    typealias RowEntity = RowEliminationWorker<R>.RowElement
    
    public let size: (rows: Int, cols: Int)
    private let worker: RowEliminationWorker<R>
    
    private var pivots: [Int : Int] // column -> pivot row
    private var pivotRows: Set<Int>

    private var debug: Bool = true
    
    public init<S: Sequence>(size: (rows: Int, cols: Int), components: S) where S.Element == MatrixComponent<R> {
        self.size = size
        self.worker = RowEliminationWorker(size: size, components: components, trackRowInfos: true)
        self.pivots = [:]
        self.pivotRows = []
    }
    
    public func start() -> [(Int, Int)] {
        findFLPivots()
        findFLColumnPivots()
        findCycleFreePivots()
        return sortPivots()
    }
    
    // Faugère-Lachartre pivot search
    private func findFLPivots() {
        let n = size.rows
        var pivots: [Int : Int] = [:] // col -> row
        
        for i in 0 ..< n {
            let row = self.row(i)
            guard let head = row.headElement else {
                continue
            }
            let (j, a) = (head.col, head.value)
            
            if !a.isInvertible {
                continue
            }
            
            if pivots[j] == nil || isBetter(i, than: pivots[j]!) {
                pivots[j] = i
            }
        }
        
        pivots.forEach{ (j, i) in setPivot(i, j) }
        print("FL-pivots:", currentPivots())
    }
    
    private func findFLColumnPivots() {
        let n = size.rows
        var reservedCols = Set(pivotRows.flatMap{ i in
            row(i).map { $0.col }
        })
        
        for i in 0 ..< n {
            let row = worker.row(i)
            var isPivotRow = pivotRows.contains(i)
            
            for (j, a) in row where !reservedCols.contains(j) {
                reservedCols.insert(j)
                
                if !isPivotRow && a.isInvertible {
                    setPivot(i, j)
                    isPivotRow = true
                }
            }
        }
        
        print("FL-col-pivots:", currentPivots())
    }
    
    private func findCycleFreePivots() {
        let n = size.rows
        let rows = (0 ..< n).compactMap { i -> (Int, LinkedList<RowEntity>)? in
            if pivotRows.contains(i) {
                return nil
            }
            let row = self.row(i)
            return row.isEmpty ? nil : (i, row)
        }
        
        let atomic = DispatchQueue(label: "atomic", qos: .userInteractive)
        
        rows.parallelForEach { row in
            var retry = 0
            while true {
                let pivotsLocal = atomic.sync { self.pivots }
                let nPivLocal = pivotsLocal.count
                
                if let pivot = self.findCycleFreePivot(inRow: row, pivots: pivotsLocal) {
                    let nPiv = atomic.sync { self.pivotRows.count }
                    if nPiv == nPivLocal {
                        atomic.sync { self.setPivot(pivot) }
                        break
                    } else {
                        retry += 1
                        // pivots have been updated, retry
                        continue
                    }
                } else {
                    break
                }
            }
        }
        
        print("cycle-free-pivots:", currentPivots())
    }
    
    private func findCycleFreePivot(inRow row: (Int, LinkedList<RowEntity>), pivots: [Int : Int]) -> (Int, Int)? {
        let (i, list) = row
        
        var queue: [Int] = []
        var candidates: Set<Int> = []
        var visited: Set<Int> = []
        
        // initialize
        for (j, a) in list {
            if pivots.contains(key: j) {
                queue.append(j)
            } else if a.isInvertible {
                candidates.insert(j)
            }
        }
        
        queueLoop: while !queue.isEmpty {
            let j = queue.removeFirst()
            let k = pivots[j]!
            
            for (l, _) in self.row(k) {
                if pivots.contains(key: l) && !visited.contains(l) {
                    queue.append(l)
                    visited.insert(l)
                } else if candidates.contains(l) {
                    candidates.remove(l)
                    if candidates.isEmpty {
                        break queueLoop
                    }
                }
            }
        }
        
        // TODO take the one with min weight
        if let j = candidates.anyElement {
            return (i, j)
        } else {
            return nil
        }
    }
    
    private func sortPivots() -> [(Int, Int)] {
        let tree = Dictionary(keys: pivots.keys) { j -> [Int] in
            let i = pivots[j]!
            return self.row(i).compactMap { (k, _) -> Int? in
                if k != j && pivots[k] != nil {
                    return k
                } else {
                    return nil
                }
            }
        }
        let sorted = try! topologicalSort(tree.keys.toArray(), successors: { j in tree[j] ?? [] })
        return sorted.map{ j in (pivots[j]!, j) }
    }
    
    // for debug
    private func currentPivots() -> [(Int, Int)] {
        pivots.map{ (j, i) in (i, j) }.sorted{ $0.0 }
    }
    
    private func setPivot(_ p: (Int, Int)) {
        setPivot(p.0, p.1)
    }
        
    private func setPivot(_ i: Int, _ j: Int) {
        pivots[j] = i
        pivotRows.insert(i)
    }
    
    private func isBetter(_ i1: Int, than i2: Int) -> Bool {
        guard
            let w1 = row(i1).headElement?.value.matrixEliminationWeight,
            let w2 = row(i2).headElement?.value.matrixEliminationWeight else {
                fatalError()
        }
        
        return w1 < w2 || w1 == w2 && rowWeight(i1) < rowWeight(i2)
    }
    
    private func row(_ i: Int) -> LinkedList<RowEntity> {
        worker.row(i)
    }
    
    private func rowWeight(_ i: Int) -> Int {
        worker.rowWeight(i)
    }
}
