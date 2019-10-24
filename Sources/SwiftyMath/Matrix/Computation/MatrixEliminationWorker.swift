//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class RowEliminationWorker<R: EuclideanRing> {
    var size: (rows: Int, cols: Int)
    
    private var working: [EntityPointer?]
    private var tracker: Tracker?
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        
        let group = components
            .group{ c in c.row }
            .mapValues { l in Entity.generatePointers(from: l) }
        
        self.working = (0 ..< size.0).map { i in group[i] }
        self.tracker = trackRowInfos ? Tracker(size, working) : nil
    }
    
    convenience init<n, m>(_ A: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: A.size, components: A.nonZeroComponents, trackRowInfos: trackRowInfos)
    }
    
    deinit {
        for head in working where head != nil {
            var p = head!
            while true {
                let next = p.pointee.next
                
                p.delete()
                
                if let next = next {
                    p = next
                } else {
                    break
                }
            }
        }
    }
    
    var components: [MatrixComponent<R>] {
        working.enumerated().flatMap { (i, head) in
            head?.pointee.map{ (j, a) in (i, j, a) } ?? []
        }
    }
    
    func headComponent(ofRow i: Int) -> MatrixComponent<R>? {
        if let e = working[i]?.pointee {
            return (i, e.col, e.value)
        } else {
            return nil
        }
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
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        tracker?.rows(inCol: j).map{ i in (i, j, working[i]!.pointee.value) } ?? []
    }
    
    func weight(ofRow i: Int) -> Int {
        tracker?.weight(ofRow: i) ?? 0
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
        guard let head = working[i] else {
            return
        }
        
        var p = head
        while true {
            p.pointee.value = r * p.pointee.value
            if let next = p.pointee.next {
                p = next
            } else {
                break
            }
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        tracker?.swap(
            (i, headComponent(ofRow: i)?.col),
            (j, headComponent(ofRow: j)?.col)
        )
        working.swapAt(i, j)
    }
    
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = working[i1]?.pointee else {
            return
        }
        
        let oldToHead = working[i2]
        let oldCol = oldToHead?.pointee.col
        
        let (toHead, weightDiff) = addRow(fromHead, oldToHead, r)
        
        if toHead != oldToHead {
            working[i2] = toHead
        }
        
        tracker?.addRowWeight(weightDiff, to: i2)
        tracker?.updateRowHead(i2, oldCol, toHead?.pointee.col)
    }
    
    func batchAddRow(at i1: Int, to rows: [Int], multipliedBy rs: [R]) {
        guard let fromHead = working[i1]?.pointee else {
            return
        }
        
        let oldCols = rows.map{ i in working[i]?.pointee.col }
        let toHeads = zip(rows, rs)
            .map{ (i, r) in (working[i], r) }
            .parallelMap { (toHead, r) in addRow(fromHead, toHead, r) }
        
        for (i, res) in zip(rows, toHeads) {
            let (toHead, dw) = res
            
            working[i] = toHead
            tracker?.addRowWeight(dw, to: i)
        }
        
        for (i, oldCol) in zip(rows, oldCols) {
            tracker?.updateRowHead(i, oldCol, working[i]?.pointee.col)
        }
    }
    
    @_specialize(where R == 𝐙)
    private func addRow(_ fromHead: Entity, _ toHeadOpt: EntityPointer?, _ r: R) -> (EntityPointer?, Int) {
        var dw = 0
        let track = (tracker != nil)
        
        let toHead = {() -> EntityPointer in
            if toHeadOpt == nil || fromHead.col < toHeadOpt!.pointee.col {
                
                // from: ●-->○-->○----->○-------->
                //   to:            ●------->○--->
                //
                //   ↓
                //
                // from: ●-->○-->○----->○-------->
                //   to: ●--------->○------->○--->
                
                return EntityPointer.new(Entity(col: fromHead.col, value: .zero, next: toHeadOpt))
                
            } else {
                return toHeadOpt!
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
                    drop.delete()
                } else {
                    to.pointee.value = a
                }
                
                if track {
                    dw += a.euclideanDegree - a0.euclideanDegree
                }
                
            } else {
                let a = r * from.value
                let p = EntityPointer.new( Entity(col: from.col, value: a) )
                to.pointee.insertNext(p)
                (prev, to) = (to, p)
                
                if track {
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
            defer { toHead.delete() }
            if let next = toHead.pointee.next {
                return (next, dw)
            } else {
                return (nil, dw)
            }
        } else {
            return (toHead, dw)
        }
    }
    
    static func identity(size n: Int) -> RowEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return RowEliminationWorker(size: (n, n), components: comps)
    }
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix(size: size) { setEntry in
            for (i, headOpt) in working.enumerated() {
                guard let head = headOpt else { continue }
                for (j, a) in head.pointee {
                    setEntry(i, j, a)
                }
            }
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
        
        static func generatePointers<S: Sequence>(from seq: S) -> EntityPointer where S.Element == MatrixComponent<R> {
            let sorted = seq.sorted { c in c.col }

            var head: EntityPointer?
            var prev: EntityPointer?
            
            for (_, j, a) in sorted {
                let p = EntityPointer.new( Entity(col: j, value: a) )

                if head == nil {
                    head = p
                }
                
                prev?.pointee.next = p
                prev = p
            }
            
            return head!
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
    
    private final class Tracker {
        private var rowWeights: [Int]
        private var col2rowHead: [Set<Int>] // [col : { rows having head at col }]

        init(_ size: (Int, Int), _ working: [EntityPointer?]) {
            self.rowWeights = working
                .map{ l in l?.pointee.sum{ c in c.value.euclideanDegree } ?? 0 }
            
            let sets = working
                .enumerated()
                .compactMap{ (i, head) in head == nil ? nil : (i, head!.pointee.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
            self.col2rowHead = (0 ..< size.1).map { j in sets[j] ?? [] }
        }
        
        func weight(ofRow i: Int) -> Int {
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

internal final class ColEliminationWorker<R: EuclideanRing> {
    private let rowWorker: RowEliminationWorker<R>
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        rowWorker = RowEliminationWorker(size: (size.1, size.0), components: components.map{(i, j, a) in (j, i, a)})
    }
    
    convenience init<n, m>(_ A: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: A.size, components: A.nonZeroComponents, trackRowInfos: trackRowInfos)
    }
    
    var size: (Int, Int) {
        (rowWorker.size.cols, rowWorker.size.rows)
    }
    
    func apply(_ s: ColElementaryOperation<R>) {
        rowWorker.apply(s.transposed)
    }
    
    var components: [MatrixComponent<R>] {
        rowWorker.components.map{ (i, j, a) in (j, i, a) }
    }
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        rowWorker.resultAs(Matrix<m, n, R>.self).transposed
    }
    
    static func identity(size n: Int) -> ColEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return ColEliminationWorker(size: (n, n), components: comps)
    }
}

private extension UnsafeMutablePointer {
    static func new(_ entity: Pointee) -> Self {
        let p = allocate(capacity: 1)
        p.initialize(to: entity)
        return p
    }
    
    func delete() {
        self.deinitialize(count: 1)
        self.deallocate()
    }
}
