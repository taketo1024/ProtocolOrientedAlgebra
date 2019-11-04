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
    typealias Row = RowEliminationData<R>.Row
    
    private let data: RowAlignedMatrixData<R>
    private let rowWeights: [Int]
    
    private var pivots: [Int : ColComponent<R>] // column -> (row, value)
    private var pivotRows: Set<Int>
    private var debug: Bool
    
    public static func findPivots<n, m>(of A: Matrix<n, m, R>, debug: Bool = false) -> Result<n, m, R> {
        let size = A.size
        let pf = MatrixPivotFinder(A, debug: debug)
        let pivots = pf.findPivots()
        
        func asPermutation<n>(_ order: [Int], _ n: Int) -> Permutation<n> {
            let remain = Set(0 ..< n).subtracting(order)
            return Permutation(order + remain.sorted()).inverse!
        }
        
        let rowP: Permutation<n> = asPermutation(pivots.map{ $0.0 }, size.rows)
        let colP: Permutation<m> = asPermutation(pivots.map{ $0.1 }, size.cols)
        
        return Result(
            pivots: pivots,
            rowPermutation: rowP,
            colPermutation: colP
        )
    }
    
    private init<n, m>(_ A: Matrix<n, m, R>, debug: Bool = false) {
        self.data = RowAlignedMatrixData(A)
        self.rowWeights = data.rows.map{ $0.sum{ $0.value.matrixEliminationWeight } }
        self.pivots = [:]
        self.pivotRows = []
        self.debug = debug
    }
    
    private var size: (rows: Int, cols: Int) {
        data.size
    }
    
    private func findPivots() -> [MatrixComponent<R>] {
        findFLPivots()
        findFLColumnPivots()
        findCycleFreePivots()
        return sortPivots()
    }
    
    // Faugère-Lachartre pivot search
    private func findFLPivots() {
        let n = size.rows
        var pivots: [Int : ColComponent<R>] = [:] // col -> row
        
        for i in 0 ..< n {
            let row = self.row(i)
            guard let head = row.headElement else {
                continue
            }
            let (j, a) = (head.col, head.value)
            
            if !a.isInvertible {
                continue
            }
            
            if pivots[j] == nil || isBetter(i, than: pivots[j]!.0) {
                pivots[j] = (i, a)
            }
        }
        
        pivots.forEach{ (j, c) in
            let (i, a) = c
            setPivot(i, j, a)
        }
        
        log("FL-pivots: \(pivots.count)")
    }
    
    private func findFLColumnPivots() {
        let n = size.rows
        var reservedCols = Set(pivotRows.flatMap{ i in
            row(i).map { $0.col }
        })
        
        for i in 0 ..< n {
            var isPivotRow = pivotRows.contains(i)
            for (j, a) in row(i) where !reservedCols.contains(j) {
                reservedCols.insert(j)
                
                if !isPivotRow && a.isInvertible {
                    setPivot(i, j, a)
                    isPivotRow = true
                }
            }
        }
        
        log("FL-col-pivots: \(pivots.count)")
    }
    
    private func findCycleFreePivots() {
        let n = size.rows
        let rows = (0 ..< n).compactMap { i -> (Int, Row)? in
            if pivotRows.contains(i) {
                return nil
            }
            let row = self.row(i)
            return row.isEmpty ? nil : (i, row)
        }
        
        let atomic = DispatchQueue(label: "atomic", qos: .userInteractive)
        
        rows.parallelForEach { row in
            var found = false
            while !found {
                let pivotsLocal = atomic.sync {
                    self.pivots.mapValues{ (i, _) in i }
                }
                let nPivLocal = pivotsLocal.count
                
                guard let pivot = self.findCycleFreePivot(inRow: row, pivots: pivotsLocal) else {
                    break
                }
                
                atomic.sync {
                    let nPiv = self.pivots.count
                    if nPiv == nPivLocal {
                        self.setPivot(pivot)
                        found = true
                    }
                }
            }
        }
        
        log("cycle-free-pivots: \(pivots.count)")
    }
    
    private func findCycleFreePivot(inRow row: (Int, Row), pivots: [Int : Int]) -> (Int, Int, R)? {
        let (i, list) = row
        
        var queue: [Int] = []
        var candidates: Set<Int> = []
        var values: [Int : R] = [:]
        var visited: Set<Int> = []
        
        // initialize
        for (j, a) in list {
            if pivots.contains(key: j) {
                queue.append(j)
            } else if a.isInvertible {
                candidates.insert(j)
                values[j] = a
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
        if let j = candidates.anyElement, let a = values[j] {
            return (i, j, a)
        } else {
            return nil
        }
    }
    
    private func sortPivots() -> [MatrixComponent<R>] {
        let tree = Dictionary(keys: pivots.keys) { j -> [Int] in
            let (i, _) = pivots[j]!
            return self.row(i).compactMap { (k, _) -> Int? in
                if k != j && pivots[k] != nil {
                    return k
                } else {
                    return nil
                }
            }
        }
        let sorted = try! topologicalSort(tree.keys.toArray(), successors: { j in tree[j] ?? [] })
        return sorted.map{ j in
            let (i, a) = pivots[j]!
            return (i, j, a)
        }
    }
    
    private func setPivot(_ c: MatrixComponent<R>) {
        let (i, j, a) = c
        setPivot(i, j, a)
    }
        
    private func setPivot(_ i: Int, _ j: Int, _ a: R) {
        pivots[j] = (i, a)
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
    
    private func row(_ i: Int) -> Row {
        data.row(i)
    }
    
    private func rowWeight(_ i: Int) -> Int {
        rowWeights[i]
    }
    
    private func log(_ msg: @autoclosure () -> String) {
        if debug {
            print(msg())
        }
    }
    
    public struct Result<n: SizeType, m: SizeType, R: Ring> {
        public let pivots: [MatrixComponent<R>]
        public let rowPermutation: Permutation<n>
        public let colPermutation: Permutation<m>
        public var numberOfPivots: Int { pivots.count }
    }
}
