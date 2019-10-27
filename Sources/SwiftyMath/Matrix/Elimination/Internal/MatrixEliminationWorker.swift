//
//  RowSortedMatrix.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/10/16.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

final class RowEliminationWorker<R: Ring> {
    var size: (rows: Int, cols: Int)
    
    private var rowHeadPtrs: [EntityPointer?]
    private var tracker: Tracker?
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        
        let group = components
            .group{ c in c.row }
            .mapValues { l in Entity.generateList(from: l) }
        
        self.rowHeadPtrs = (0 ..< size.0).map { i in group[i] }
        self.tracker = trackRowInfos ? Tracker(size, rowHeadPtrs) : nil
    }
    
    convenience init<n, m>(_ A: Matrix<n, m, R>, trackRowInfos: Bool = false) {
        self.init(size: A.size, components: A.nonZeroComponents, trackRowInfos: trackRowInfos)
    }
    
    deinit {
        for p in rowHeadPtrs where p != nil {
            Entity.deleteList(startingFrom: p!)
        }
    }
    
    @inlinable
    func rowHead(_ i: Int) -> Entity? {
        rowHeadPtrs[i]?.pointee
    }
    
    @inlinable
    func rowWeight(_ i: Int) -> Int {
        tracker?.rowWeight(i) ?? 0
    }
    
    var components: [MatrixComponent<R>] {
        (0 ..< size.rows).flatMap { i in
            rowHead(i)?.sequence.map{ (j, a) in (i, j, a) } ?? []
        }
    }
    
    func components(inCol j0: Int, withinRows rowRange: CountableRange<Int>) -> [MatrixComponent<R>] {
        rowRange.compactMap { i -> MatrixComponent<R>? in
            guard let seq = rowHead(i)?.sequence else {
                return nil
            }
            for (j, a) in seq {
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
        rowHead(i).map{ e in (i, e.col, e.value) }
    }
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        tracker?.rows(inCol: j).map{ i in (i, j, rowHead(i)!.value) } ?? []
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
        guard let headPtr = rowHeadPtrs[i] else {
            return
        }
        Entity.modifyList(startingFrom: headPtr) { e in
            e.value = r * e.value
        }
    }
    
    func swapRows(_ i: Int, _ j: Int) {
        tracker?.swap(
            (i, headComponent(ofRow: i)?.col),
            (j, headComponent(ofRow: j)?.col)
        )
        rowHeadPtrs.swapAt(i, j)
    }
    
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = rowHead(i1) else {
            return
        }
        
        let oldToHeadPtr = rowHeadPtrs[i2]
        let oldCol = oldToHeadPtr?.pointee.col
        
        let (toHeadPtr, weightDiff) = addRow(fromHead, oldToHeadPtr, r)
        
        if toHeadPtr != oldToHeadPtr {
            rowHeadPtrs[i2] = toHeadPtr
        }
        
        tracker?.addRowWeight(weightDiff, to: i2)
        tracker?.updateRowHead(i2, oldCol, rowHead(i2)?.col)
    }
    
    func batchAddRow(at i1: Int, to rows: [Int], multipliedBy rs: [R]) {
        guard let fromHead = rowHead(i1) else {
            return
        }
        
        let oldCols = rows.map{ i in rowHead(i)?.col }
        let toHeadPtrs = zip(rows, rs)
            .map{ (i, r) in (rowHeadPtrs[i], r) }
            .parallelMap { (toHeadPtr, r) in addRow(fromHead, toHeadPtr, r) }
        
        for (i, res) in zip(rows, toHeadPtrs) {
            let (toHeadPtr, dw) = res
            
            rowHeadPtrs[i] = toHeadPtr
            tracker?.addRowWeight(dw, to: i)
        }
        
        for (i, oldCol) in zip(rows, oldCols) {
            tracker?.updateRowHead(i, oldCol, rowHead(i)?.col)
        }
    }
    
    @_specialize(where R == 𝐙)
    private func addRow(_ fromHead: Entity, _ initialToHeadPtr: EntityPointer?, _ r: R) -> (EntityPointer?, Int) {
        var dw = 0
        let track = (tracker != nil)
        
        let toHeadPtr = {() -> EntityPointer in
            if initialToHeadPtr == nil || fromHead.col < initialToHeadPtr!.pointee.col {
                
                // from: ●-->○-->○----->○-------->
                //   to:            ●------->○--->
                //
                //   ↓
                //
                // from: ●-->○-->○----->○-------->
                //   to: ●--------->○------->○--->
                
                return EntityPointer.new(Entity(col: fromHead.col, value: .zero, next: initialToHeadPtr))
                
            } else {
                return initialToHeadPtr!
            }
        }()
        
        var (from, toPtr) = (fromHead, toHeadPtr)
        var prev = toPtr
        
        while true {
            // At this point, it is assured that
            // `from.value.col >= to.value.col`
            
            // from: ------------->●--->○-------->
            //   to: -->●----->○------------>○--->
            
            while let next = toPtr.pointee.next, next.pointee.col <= from.col {
                (prev, toPtr) = (toPtr, next)
            }
            
            // from: ------------->●--->○-------->
            //   to: -->○----->●------------>○--->

            if from.col == toPtr.pointee.col {
                let a0 = toPtr.pointee.value
                let a = a0 + r * from.value
                
                if a.isZero && toPtr != prev {
                    toPtr = prev
                    let drop = toPtr.pointee.dropNext()!
                    drop.delete()
                } else {
                    toPtr.pointee.value = a
                }
                
                if track {
                    dw += a.matrixEliminationWeight - a0.matrixEliminationWeight
                }
                
            } else {
                let a = r * from.value
                let p = EntityPointer.new( Entity(col: from.col, value: a) )
                toPtr.pointee.insertNext(p)
                (prev, toPtr) = (toPtr, p)
                
                if track {
                    dw += a.matrixEliminationWeight
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
        
        if toHeadPtr.pointee.value.isZero {
            defer { toHeadPtr.delete() }
            if let next = toHeadPtr.pointee.next {
                return (next, dw)
            } else {
                return (nil, dw)
            }
        } else {
            return (toHeadPtr, dw)
        }
    }
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix(size: size) { setEntry in
            for i in (0 ..< size.rows) {
                guard let seq = rowHead(i)?.sequence else {
                    continue
                }
                for (j, a) in seq {
                    setEntry(i, j, a)
                }
            }
        }
    }
    
    typealias EntityPointer = UnsafeMutablePointer<Entity>
    
    struct Entity: Equatable {
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
        
        static func generateList<S: Sequence>(from seq: S) -> EntityPointer where S.Element == MatrixComponent<R> {
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
        
        static func deleteList(startingFrom headPtr: EntityPointer) {
            var p = headPtr
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
        
        static func modifyList(startingFrom headPtr: EntityPointer, _ map: (inout Entity) -> Void) {
            var p = headPtr
            while true {
                map(&(p.pointee))
                if let next = p.pointee.next {
                    p = next
                } else {
                    break
                }
            }
        }
        
        var sequence: IteratorSequence<Iterator> {
            IteratorSequence(Iterator(self))
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
                .map{ l in l?.pointee.sequence.sum{ c in c.value.matrixEliminationWeight } ?? 0 }
            
            let sets = working
                .enumerated()
                .compactMap{ (i, head) in head == nil ? nil : (i, head!.pointee.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
            self.col2rowHead = (0 ..< size.1).map { j in sets[j] ?? [] }
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
