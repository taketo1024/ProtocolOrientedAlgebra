//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class RowEliminationWorker<R: EuclideanRing>: Equatable {
    var size: (rows: Int, cols: Int)
    
    typealias Table = [Int : LinkedList<(col: Int, value: R)>]
    
    private var working: Table
    private var trackRowInfos: Bool
    private var rowWeights: [Int : Int]
    private var col2rowTable: [Int : Set<Int>] // [col : { rows having head at col }]
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        self.working = components.group{ c in c.row }
            .mapValues { l in
                let sorted = l.sorted{ c in c.col }.map{ c in (c.col, c.value) }
                return LinkedList.generate(from: sorted)!
        }
        
        self.trackRowInfos = trackRowInfos
        if trackRowInfos {
            self.rowWeights = working
                .mapValues{ l in l.sum{ c in c.value.euclideanDegree } }
            
            self.col2rowTable = working
                .map{ (i, head) in (i, head.value.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
        } else {
            self.rowWeights = [:]
            self.col2rowTable = [:]
        }
    }
    
    var components: [MatrixComponent<R>] {
        working.flatMap { (i, list) in
            list.map{ (j, a) in (i, j, a) }
        }
    }
    
    func headComponent(ofRow i: Int) -> MatrixComponent<R>? {
        if let (j, a) = working[i]?.value {
            return (i, j, a)
        } else {
            return nil
        }
    }
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        col2rowTable[j]?.map { i in (i, j, working[i]!.value.value) } ?? []
    }
    
    func components(inCol j0: Int, withinRows rowRange: CountableRange<Int>) -> [MatrixComponent<R>] {
        rowRange.compactMap { i -> MatrixComponent<R>? in
            guard let head = working[i] else {
                return nil
            }
            for (j, a) in head {
                if j == j0 {
                    return (i, j, a)
                } else if j > j0 {
                    return nil
                }
            }
            return nil
        }
    }
    
    func weight(ofRow i: Int) -> Int {
        rowWeights[i] ?? 0
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
        assert(!r.isZero)
        var p = working[i]
        while let c = p {
            c.value.value = r * c.value.value
            p = c.next
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        if trackRowInfos {
            removeFromCol2RowTable(i)
            removeFromCol2RowTable(j)
        }

        (working[i], working[j]) = (working[j], working[i])
        
        if trackRowInfos {
            insertToCol2RowTable(i)
            insertToCol2RowTable(j)
            (rowWeights[i], rowWeights[j]) = (rowWeights[j], rowWeights[i])
        }
    }
    
    @_specialize(where R == 𝐙)
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = working[i1] else {
            return
        }
        
        if trackRowInfos {
            removeFromCol2RowTable(i2)
        }

        let toHead = {() -> LinkedList<(col: Int, value: R)> in
            let toHead = working[i2] // possibly nil
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
        
        let result = toHead.drop{ c in c.value.isZero } // possibly nil
        
        working[i2] = result
        
        if trackRowInfos {
            insertToCol2RowTable(i2)
            updateRowWeight(i2)
        }
    }
    
    private func updateRowWeight(_ i: Int) {
        if let head = working[i] {
            rowWeights[i] = head.sum{ c in c.value.euclideanDegree }
        } else {
            rowWeights[i] = nil
        }
    }
    
    private func removeFromCol2RowTable(_ i: Int) {
        guard let j = working[i]?.value.col else { return }
        if col2rowTable[j]!.count == 1 {
            col2rowTable[j] = nil
        } else {
            col2rowTable[j]!.remove(i)
        }
    }
    
    private func insertToCol2RowTable(_ i: Int) {
        guard let j = working[i]?.value.col else { return }
        if col2rowTable[j] == nil {
            col2rowTable[j] = [i]
        } else {
            col2rowTable[j]!.insert(i)
        }
    }
    
    static func identity(size n: Int) -> RowEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return RowEliminationWorker(size: (n, n), components: comps)
    }

    // for test
    static func ==(a: RowEliminationWorker, b: RowEliminationWorker) -> Bool {
        (a.working.keys == b.working.keys) && a.working.keys.allSatisfy{ i in
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
    
    func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        switch s {
        case .AddCol, .MulCol, .SwapCols:
            rowWorker.apply(s.transposed)
        default:
            fatalError()
        }
    }
    
    var components: [MatrixComponent<R>] {
        rowWorker.components.map{ (i, j, a) in (j, i, a) }
    }
    
    static func identity(size n: Int) -> ColEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return ColEliminationWorker(size: (n, n), components: comps)
    }
    
    // for test
    static func ==(a: ColEliminationWorker, b: ColEliminationWorker) -> Bool {
        a.rowWorker == b.rowWorker
    }
}
