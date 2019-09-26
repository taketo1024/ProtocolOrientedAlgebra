public protocol FreeModuleType: Module {
    associatedtype Generator: FreeModuleGenerator
    init<S: Sequence>(_ elements: S) where S.Element == (Generator, BaseRing)
    static func wrap(_ a: Generator) -> Self
    func unwrap() -> Generator?
    var isGenerator: Bool { get }
    func decomposed() -> [(Generator, BaseRing)]
}

public struct FreeModule<A: FreeModuleGenerator, R: Ring>: FreeModuleType {
    public typealias BaseRing = R
    public typealias Generator = A
    
    private let elements: [(A, R)]
    private let dictCache: Cache<[A : R]> = .empty
    
    public init<S: Sequence>(_ elements: S) where S.Element == (A, R) {
        assert(elements.map{ $0.0 }.isUnique)
        self.elements = Array(elements.exclude{ (_, r) in r == .zero })
    }
    
    public init(_ elements: (A, R)...) {
        self.init(elements)
    }
    
    public subscript(a: A) -> R {
        if !dictCache.hasValue {
            dictCache.value = Dictionary(pairs: elements)
        }
        return dictCache.value?[a] ?? .zero
    }
    
    @_transparent
    public static func wrap(_ a: A) -> FreeModule<A, R> {
        FreeModule([(a, .identity)])
    }
    
    public func unwrap() -> A? {
        isGenerator ? elements.first!.0 : nil
    }
    
    public var isGenerator: Bool {
        (elements.count == 1) && (elements.first!.1 == .identity)
    }
    
    public static var zero: FreeModule<A, R> {
        FreeModule([])
    }
    
    public static func combine<n>(generators: [A], vector: ColVector<n, R>) -> FreeModule<A, R> {
        assert(generators.count == vector.size.rows)
        return (generators.map{ .wrap($0) } * vector)[0]
    }
    
    public var degree: Int {
        if let (a, r) = elements.first {
            return a.degree + r.degree
        } else {
            return 0
        }
    }
    
    public var generators: [A] {
        elements.map{ $0.0 }
    }
    
    public func decomposed() -> [(A, R)] {
        elements
    }
    
    public func mapGenerators<A2>(_ f: (A) -> A2) -> FreeModule<A2, R> {
        FreeModule<A2, R>(elements.map{ (a, r) in (f(a), r) })
    }
    
    public func mapComponents<R2>(_ f: (R) -> R2) -> FreeModule<A, R2> {
        FreeModule<A, R2>(elements.map{ (a, r) in (a, f(r)) })
    }
    
    public func map<A2, R2>(_ f: (A, R) -> (A2, R2)) -> FreeModule<A2, R2> {
        FreeModule<A2, R2>(elements.map{ (a, r) in f(a, r) })
    }
    
    public var reordered: FreeModule {
        FreeModule(elements.sorted{ (a, _) in a })
    }
    
    public static func + (a: FreeModule<A, R>, b: FreeModule<A, R>) -> FreeModule<A, R> {
        FreeModule.sum([a, b])
    }
    
    public static prefix func - (a: FreeModule<A, R>) -> FreeModule<A, R> {
        FreeModule<A, R>(a.elements.map{ (a, r) in (a, -r) })
    }
    
    public static func * (r: R, a: FreeModule<A, R>) -> FreeModule<A, R> {
        FreeModule<A, R>(a.elements.map{ (a, s) in (a, r * s) })
    }
    
    public static func * (a: FreeModule<A, R>, r: R) -> FreeModule<A, R> {
        FreeModule<A, R>(a.elements.map{ (a, s) in (a, s * r) })
    }
    
    public static func sum(_ elements: [FreeModule<A, R>]) -> FreeModule<A, R> {
        if elements.count == 1 {
            return elements.first!
        } else {
            var dict: [A : R] = [:]
            var gens: [A] = []
            
            let size = elements.sum { z in z.elements.count }
            dict.reserveCapacity(size)
            gens.reserveCapacity(size)
            
            for z in elements {
                for (a, r) in z.elements {
                    if let r0 = dict[a] {
                        dict[a] = r0 + r
                    } else {
                        dict[a] = r
                        gens.append(a)
                    }
                }
            }
            return FreeModule(gens.map{ a in (a, dict[a]!) })
        }
    }
    
    public static func ==(lhs: FreeModule, rhs: FreeModule) -> Bool {
        lhs.elements.count == rhs.elements.count
            && Dictionary(pairs: lhs.elements) == Dictionary(pairs: rhs.elements)
    }
    
    public var description: String {
        Format.terms("+", elements.map { (a, r) in (r, a.description, 1) })
    }
    
    public static var symbol: String {
        "FreeMod(\(R.symbol))"
    }
}

extension FreeModule where R: RealSubset {
    public var asReal: FreeModule<A, 𝐑> {
        mapComponents{ $0.asReal }
    }
}

extension FreeModule where R: ComplexSubset {
    public var asComplex: FreeModule<A, 𝐂> {
        mapComponents{ $0.asComplex }
    }
}

extension ModuleHom where X: FreeModuleType, Y: FreeModuleType {
    public static func linearlyExtend(_ f: @escaping (X.Generator) -> Codomain) -> ModuleHom<X, Y> {
        ModuleHom { (m: Domain) in
            m.isGenerator ? f(m.unwrap()!) : m.decomposed().sum { (a, r) in r * f(a) }
        }
    }
}

//extension FreeModule: Codable where A: Codable, R: Codable {}
