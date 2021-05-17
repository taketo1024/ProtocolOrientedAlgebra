//
//  LinkedList.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/27.
//

internal final class LinkedList<Element>: Sequence {
    typealias NodePointer = UnsafeMutablePointer<Node>
    struct Node {
        var element: Element
        var next: NodePointer? = nil
        
        mutating func insertNext(_ e: Element) {
            let p = NodePointer.new( Node(element: e, next: self.next) )
            self.next = p
        }
        
        mutating func dropNext() {
            guard let drop = next else {
                return
            }
            self.next = drop.pointee.next
            drop.delete()
        }
    }
    
    private var head: NodePointer? = nil
    
    init<S: Sequence>(_ seq: S) where S.Element == Element {
        var head: NodePointer?
        var prev: NodePointer?
        
        for e in seq {
            let p = NodePointer.new( Node(element: e) )

            if head == nil {
                head = p
            }
            
            prev?.pointee.next = p
            prev = p
        }
        
        self.head = head
    }
    
    convenience init() {
        self.init([])
    }
    
    deinit {
        removeAll()
    }
    
    var isEmpty: Bool {
        head == nil
    }
    
    var headElement: Element? {
        head?.pointee.element
    }
    
    var headPointer: NodePointer? {
        head
    }
    
    func insertHead(_ element: Element) {
        head = NodePointer.new( Node(element: element, next: head) )
    }
    
    func dropHead() {
        guard let head = head else {
            return
        }
        defer { head.delete() }
        self.head = head.pointee.next
    }
    
    func removeAll() {
        var p = head
        while p != nil {
            let next = p?.pointee.next
            
            p!.delete()
            p = next
        }
        head = nil
    }
    
    func modifyEach(_ map: (inout Element) -> Void) {
        var pItr = makePointerIterator()
        while let p = pItr.next() {
            map(&(p.pointee.element))
        }
    }
    
    func find(_ predicate1: (Element) -> Bool, while predicate2: (Element) -> Bool) -> (hit: NodePointer?, prev: NodePointer?) {
        var pItr = makePointerIterator()
        var prev: NodePointer? = nil
        
        while let p = pItr.next() {
            let e = p.pointee.element
            if !predicate2(e) {
                break
            }
            if predicate1(e) {
                return (p, prev)
            }
            prev = p
        }
        
        return (nil, prev)
    }
    
    func makeIterator() -> ElementIterator {
        ElementIterator(head?.pointee)
    }
    
    func makePointerIterator() -> PointerIterator {
        PointerIterator(head)
    }
    
    struct ElementIterator: IteratorProtocol {
        private var current: Node?
        fileprivate init(_ start: Node?) {
            current = start
        }
        
        mutating func next() -> Element? {
            defer { current = current?.next?.pointee }
            return current?.element
        }
    }
    
    struct PointerIterator: IteratorProtocol {
        private var current: NodePointer?
        fileprivate init(_ start: NodePointer?) {
            current = start
        }
        
        mutating func next() -> NodePointer? {
            defer { current = current?.pointee.next }
            return current
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
