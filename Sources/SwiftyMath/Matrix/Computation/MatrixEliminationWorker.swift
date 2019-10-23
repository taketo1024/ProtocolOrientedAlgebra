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
    private var trackRowInfos: Bool
    private var rowWeights: [Int]
    private var col2rowTable: [Set<Int>] // [col : { rows having head at col }]
    
    init<S: Sequence>(size: (Int, Int), components: S, trackRowInfos: Bool = false) where S.Element == MatrixComponent<R> {
        self.size = size
        
        let group = components
            .group{ c in c.row }
            .mapValues { l in Entity.generatePointers(from: l) }
        
        self.working = (0 ..< size.0).map { i in group[i] }
        
        if trackRowInfos {
            self.trackRowInfos = true
            self.rowWeights = working
                .map{ l in l?.pointee.sum{ c in c.value.euclideanDegree } ?? 0 }
            
            let sets = working
                .enumerated()
                .compactMap{ (i, head) in head == nil ? nil : (i, head!.pointee.col) }
                .group{ (_, j) in j }
                .mapValues{ l in Set( l.map{ (i, _) in i } ) }
            
            self.col2rowTable = (0 ..< size.1).map { j in sets[j] ?? [] }
            
        } else {
            self.trackRowInfos = false
            self.rowWeights = []
            self.col2rowTable = []
        }
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
    
    func headComponents(inCol j: Int) -> [MatrixComponent<R>] {
        col2rowTable[j].map { i in (i, j, working[i]!.pointee.value) }
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
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix<n, m, R>(size: size, components: components)
    }
    
    func weight(ofRow i: Int) -> Int {
        rowWeights[i]
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

        working.swapAt(i, j)
        
        if trackRowInfos {
            rowWeights.swapAt(i, j)
            insertToCol2RowTable(i)
            insertToCol2RowTable(j)
        }
    }
    
    @_specialize(where R == 𝐙)
    func addRow(at i1: Int, to i2: Int, multipliedBy r: R) {
        guard let fromHead = working[i1]?.pointee else {
            return
        }
        
        let w = trackRowInfos ? weight(ofRow: i2) : 0
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
                
                return EntityPointer.new(Entity(col: fromHead.col, value: .zero, next: toHead))
                
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
                    drop.delete()
                } else {
                    to.pointee.value = a
                }
                
                if trackRowInfos {
                    dw += a.euclideanDegree - a0.euclideanDegree
                }
            } else {
                let a = r * from.value
                let p = EntityPointer.new( Entity(col: from.col, value: a) )
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
            toHead.delete()
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
        col2rowTable[j].remove(i)
    }
    
    private func insertToCol2RowTable(_ i: Int) {
        guard let j = working[i]?.pointee.col else { return }
        col2rowTable[j].insert(i)
    }
    
    static func identity(size n: Int) -> RowEliminationWorker<R> {
        let comps = (0 ..< n).map { i in (i, i, R.identity) }
        return RowEliminationWorker(size: (n, n), components: comps)
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
    
    func resultAs<n, m>(_ type: Matrix<n, m, R>.Type) -> Matrix<n, m, R> {
        Matrix<n, m, R>(size: size, components: components)
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
