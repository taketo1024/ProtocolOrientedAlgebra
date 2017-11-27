import Foundation

public struct Permutation<n: _Int>: Group, FiniteSetType {
    
    public let degree: Int
    fileprivate var elements: [Int] //
    
    internal init(elements: [Int]) {
        assert(n.self == Dynamic.self || n.intValue == elements.count)
        let degree = elements.count
        
        assert({
            let set = Set(elements)
            let (num, min, max) = (degree, set.min(), set.max())
            return (set.count == num) && (min == 0) && (max == num - 1)
        }())
        
        self.degree = degree
        self.elements = elements
    }
    
    public init(_ dict: [Int: Int]) {
        self.init(generator: { dict[$0] ?? $0 })
    }
    
    public init(cyclic: Int...) {
        self.init(cyclic: cyclic)
    }
    
    internal init(cyclic: [Int]) {
        self.init(generator: { cyclic.index(of: $0).flatMap({ i in cyclic[(i + 1) % cyclic.count]}) ?? $0 })
    }
    
    public init(degree: Int? = nil, generator: ((Int) -> Int)) {
        assert( degree != nil || n.self != Dynamic.self )
        let d = degree ?? n.intValue
        let elements = (0 ..< d).map(generator)
        self.init(elements: elements)
    }
    
    public init<X: Hashable>(from: [X], to: [X]) {
        assert(Set(from) == Set(to))
        let indexTable = Dictionary(pairs: to.enumerated().map { (i, a) in (a, i) })
        self.init(elements: from.map{ indexTable[$0]! } )
    }
    
    public subscript(i: Int) -> Int {
        return elements[i]
    }
    
    public static var identity: Permutation<n> {
        return Permutation<n>{ $0 }
    }
    
    public var inverse: Permutation<n> {
        let inv = (0 ..< degree).sorted { self[$0] < self[$1] }
        return Permutation(elements: inv)
    }
    
    public func apply(_ i: Int) -> Int {
        return self[i]
    }
    
    public var signature: Int {
        let decomp = rawCyclicDecomposition
        return decomp.reduce(1){ $0 * ( $1.count % 2 == 0 ? -1 : 1) }
    }
    
    private var rawCyclicDecomposition: [[Int]] {
        var list = Array(0 ..< degree)
        var result: [[Int]] = []
        
        while !list.isEmpty {
            let a = list.first!
            var cyclic: [Int] = []
            var x = a
            
            while !cyclic.contains(x) {
                list.remove(at: list.index(of: x)!)
                cyclic.append(x)
                x = apply(x)
            }
            
            if cyclic.count > 1 {
                result.append(cyclic)
            }
        }
        
        return result
    }
    
    public var cyclicDecomposition: [Permutation<n>] {
        return rawCyclicDecomposition.map{ Permutation<n>(cyclic: $0) }
    }
    
    public func asMatrix() -> Matrix<n, n, IntegerNumber> {
        return asMatrix(type: IntegerNumber.self)
    }
    
    public func asMatrix<R: Ring>(type: R.Type) -> Matrix<n, n, R> {
        let comps = (0 ..< degree).map{ i in (i, self[i], R.identity) }
        return Matrix<n, n, R>(rows: degree, cols: degree, components: comps)
    }
    
    public static var allElements: [Permutation<n>] {
        return n.intValue.permutations.map{ Permutation(elements: $0) }
    }
    
    public static var countElements: Int {
        return n.intValue.factorial
    }
    
    public static func == (a: Permutation, b: Permutation) -> Bool {
        return a.elements == b.elements
    }
    
    public static func * (a: Permutation, b: Permutation) -> Permutation<n> {
        return Permutation{ a[b[$0]] }
    }
    
    public var description: String {
        let desc = rawCyclicDecomposition.map{"(\($0.map{"\($0)"}.joined(separator:",")))"}.joined()
        return desc.isEmpty ? "id" : desc
    }
    
    public static var symbol: String {
        return "S_\(n.intValue)"
    }
    
    public var hashValue: Int {
        return elements.count > 0 ? elements[0].hashValue + 1 : 0
    }
}

public struct AlternatingGroup<n: _Int>: Subgroup, FiniteSetType {
    public typealias Super = Permutation<n>
    
    private let g: Super
    
    public init(_ g: Super) {
        self.g = g
    }
    
    public init(_ dict: [Int: Int]) {
        self.init( Super{ dict[$0] ?? $0 })
    }
    
    public init(cyclic: Int...) {
        self.init( Super(cyclic: cyclic) )
    }
    
    public var asSuper: Super {
        return g
    }
    
    public static func contains(_ g: Super) -> Bool {
        return g.signature == 1
    }
    
    public static var allElements: [AlternatingGroup<n>] {
        return Super.allElements.filter{ $0.signature == 1 }.map{ AlternatingGroup($0) }
    }
    
    public static var countElements: Int {
        return n.intValue.factorial / 2
    }

    public static var symbol: String {
        return "A_\(n.intValue)"
    }
}
