//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class RowEliminationWorker<R: EuclideanRing>: Equatable {
    var size: (rows: Int, cols: Int)
    
    typealias Table = [Int : EntityPointer]
    
    private var working: Table
    private var pool: EntityPointerPool
    
    private var trackRowInfos: Bool
    private var rowWeights: [Int : Int]
    private var col2rowTable: [Int : Set<Int>] // [col : { rows having head at col }]
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        let pool = EntityPointerPool()
        self.size = size
        self.pool = pool
        self.working = components.group{ c in c.row }
            .mapValues { l in
                let sorted = l.sorted{ c in c.col }.map{ c in (c.col, c.value) }
                return pool.generateSequence(from: sorted)
        }
        
        self.trackRowInfos = trackRowInfos
        if trackRowInfos {
            self.rowWeights = working
                .mapValues{ l in l.pointee.sum{ c in c.value.euclideanDegree } }
            
            self.col2rowTable = working
                .map{ (i, list) in (i, list.pointee.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
        } else {
            self.rowWeights = [:]
            self.col2rowTable = [:]
        }
    }
    
    var components: [MatrixComponent<R>] {
        working.flatMap { (i, list) in
            list.pointee.map{ (j, a) in (i, j, a) }
        }
    }
    
    func headComponent(ofRow i: Int) -> MatrixComponent<R>? {
        if let e = working[i]?.pointee {
            return (i, e.col, e.value)
        } else {
            return nil
        }
    }
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        col2rowTable[j]?.map { i in (i, j, working[i]!.pointee.value) } ?? []
    }
    
    func components(inCol j0: Int, withinRows rowRange: CountableRange<Int>) -> [MatrixComponent<R>] {
        rowRange.compactMap { i -> MatrixComponent<R>? in
            guard let list = working[i]?.pointee else {
                return nil
            }
            for (j, a) in list {
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
        var pOpt = working[i]
        while let p = pOpt {
            p.pointee.value = r * p.pointee.value
            pOpt = p.pointee.next
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        if trackRowInfos {
            removeFromCol2RowTable(i)
            removeFromCol2RowTable(j)
        }

        working.swap(i, j)
        
        if trackRowInfos {
            insertToCol2RowTable(i)
            insertToCol2RowTable(j)
            rowWeights.swap(i, j)
        }
    }
    
    @_specialize(where R == 𝐙)
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = working[i1]?.pointee else {
            return
        }
        
        let w = weight(ofRow: i2)
        var dw = 0
        
        if trackRowInfos {
            removeFromCol2RowTable(i2)
        }

        let toHead = {() -> EntityPointer in
            let toHead = working[i2] // possibly nil
            if toHead == nil || fromHead.col < toHead!.pointee.col {
                
                // from: ●-->○-->○----->○-------->
                //   to:            ●------->○--->
                //
                //   ↓
                //
                // from: ●-->○-->○----->○-------->
                //   to: ●--------->○------->○--->
                
                return pool.use(col: fromHead.col, value: .zero, next: toHead)
                
            } else {
                return toHead!
            }
        }()
        
        var (from, to) = (fromHead, toHead)
        var prev = to
        
        while true {
            // At this point, it is assured that
            // `from.value.col >= to.value.col`
            
            // from: ------------->●--->○-------->
            //   to: -->●----->○------------>○--->
            
            while let next = to.pointee.next, next.pointee.col <= from.col {
                (prev, to) = (to, next)
            }
            
            // from: ------------->●--->○-------->
            //   to: -->○----->●------------>○--->

            if from.col == to.pointee.col {
                let a0 = to.pointee.value
                let a = a0 + r * from.value
                
                if a.isZero && to != prev {
                    to = prev
                    let drop = to.pointee.dropNext()!
                    pool.unuse(drop)
                } else {
                    to.pointee.value = a
                }
                
                if trackRowInfos {
                    dw += a.euclideanDegree - a0.euclideanDegree
                }
            } else {
                let a = r * from.value
                let p = pool.use(col: from.col, value: a)
                to.pointee.insertNext(p)
                (prev, to) = (to, p)
                
                if trackRowInfos {
                    dw += a.euclideanDegree
                }
            }
            
            // from: ------------->●--->○-------->
            //   to: -->○----->○-->●-------->○--->

            if let next = from.next?.pointee {
                from = next
                
                // from: ------------->○--->●-------->
                //   to: -->○----->○---●-------->○--->
                
            } else {
                break
            }
        }
        
        if toHead.pointee.value.isZero {
            if let next = toHead.pointee.next, !next.pointee.value.isZero {
                working[i2] = next
            } else {
                working[i2] = nil
            }
            pool.unuse(toHead)
        } else {
            working[i2] = toHead
        }
        
        if trackRowInfos {
            insertToCol2RowTable(i2)
            rowWeights[i2] = (working[i2] == nil) ? 0 : w + dw
        }
    }
    
    private func removeFromCol2RowTable(_ i: Int) {
        guard let j = working[i]?.pointee.col else { return }
        if col2rowTable[j]!.count == 1 {
            col2rowTable[j] = nil
        } else {
            col2rowTable[j]!.remove(i)
        }
    }
    
    private func insertToCol2RowTable(_ i: Int) {
        guard let j = working[i]?.pointee.col else { return }
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
            var itr1 = a.working[i]!.pointee.makeIterator()
            var itr2 = b.working[i]!.pointee.makeIterator()
            
            while let c1 = itr1.next(), let c2 = itr2.next() {
                if c1.value != c2.value {
                    return false
                }
            }
            return itr1.next() == nil && itr2.next() == nil
        }
    }
    
    typealias EntityPointer = UnsafeMutablePointer<Entity>
    
    struct Entity: Sequence, Equatable {
        let col: Int
        var value: R
        var next: EntityPointer? = nil
        
        mutating func insertNext(_ p: EntityPointer) {
            assert(p.pointee.next?.pointee != self)
            p.pointee.next = next
            next = p
        }
        
        mutating func dropNext() -> EntityPointer? {
            guard let drop = next else {
                return nil
            }
            self.next = drop.pointee.next
            return drop
        }
        
        func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        struct Iterator: IteratorProtocol {
            private var current: Entity?
            fileprivate init(_ start: Entity) {
                current = start
            }
            
            public mutating func next() -> (col: Int, value: R)? {
                if let e = current {
                    current = e.next?.pointee
                    return (e.col, e.value)
                } else {
                    return nil
                }
            }
        }
    }
    
    class EntityPointerPool {
        private var used: Set<EntityPointer> = []
        private var unused: Set<EntityPointer> = []
        
        func use(col: Int, value: R, next: EntityPointer? = nil) -> EntityPointer {
            let p = unused.popFirst() ?? EntityPointer.allocate(capacity: 1)
            p.initialize(to: Entity(col: col, value: value, next: next))
            used.insert(p)
            return p
        }
        
        func unuse(_ p: EntityPointer) {
            used.remove(p)
            p.deinitialize(count: 1)
            unused.insert(p)
        }
        
        func generateSequence<S: Sequence>(from seq: S) -> EntityPointer where S.Element == (Int, R) {
            var head: EntityPointer?
            var prev: EntityPointer?
            
            for (j, a) in seq {
                let p = use(col: j, value: a)
                if head == nil {
                    head = p
                }
                prev?.pointee.next = p
                prev = p
            }
            
            return head!
        }
        
        deinit {
            used.union(unused).forEach { p in
                p.deallocate()
            }
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
