public struct SymmetricGroup<n: _Int>: Group, FiniteSetType {
    
    internal let p: Permutation
    
    public init(_ p: Permutation) {
        self.p = p
    }
    
    public init(_ dict: [Int: Int]) {
        self.init(Permutation(dict))
    }
    
    public init(cyclic: Int...) {
        self.init(Permutation(cyclic: cyclic))
    }
    
    internal init(cyclic: [Int]) {
        self.init(Permutation(cyclic: cyclic))
    }
    
    public init(generator g: ((Int) -> Int)) {
        self.init(Permutation(length: n.intValue, generator: g))
    }
    
    public subscript(i: Int) -> Int {
        return p[i]
    }
    
    public static var identity: SymmetricGroup<n> {
        return SymmetricGroup(Permutation.identity)
    }
    
    public var inverse: SymmetricGroup<n> {
        return SymmetricGroup(p.inverse)
    }
    
    public var signature: Int {
        return p.signature
    }
    
    public var cyclicDecomposition: [SymmetricGroup<n>] {
        return p.cyclicDecomposition.map{ SymmetricGroup($0) }
    }
    
    public static var allElements: [SymmetricGroup<n>] {
        return Permutation.allPermutations(ofLength: n.intValue).map{ SymmetricGroup($0) }
    }
    
    public static var countElements: Int {
        return n.intValue.factorial
    }
    
    public static func == (a: SymmetricGroup, b: SymmetricGroup) -> Bool {
        return a.p == b.p
    }
    
    public static func * (a: SymmetricGroup, b: SymmetricGroup) -> SymmetricGroup<n> {
        return SymmetricGroup( a.p * b.p )
    }
    
    public var description: String {
        return p.description
    }
    
    public static var symbol: String {
        return "S_\(n.intValue)"
    }
    
    public var hashValue: Int {
        return p.hashValue
    }
}
