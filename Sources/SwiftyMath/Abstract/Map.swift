
public protocol MapType: SetType {
    associatedtype Domain: SetType
    associatedtype Codomain: SetType
    init(_ fnc: @escaping (Domain) -> Codomain)
    func applied(to x: Domain) -> Codomain
}

public extension MapType {
    public static func ==(f: Self, g: Self) -> Bool {
        fatalError("cannot equate general maps.")
    }

    public var hashValue: Int {
        return 0
    }

    public var description: String {
        return "\(Domain.symbol) -> \(Codomain.symbol)"
    }

    public static var symbol: String {
        return "Map(\(Domain.symbol), \(Codomain.symbol))"
    }
}

public struct Map<Domain: SetType, Codomain: SetType>: MapType {
    internal let fnc: (Domain) -> Codomain
    public init(_ fnc: @escaping (Domain) -> Codomain) {
        self.fnc = fnc
    }

    public func applied(to x: Domain) -> Codomain {
        return fnc(x)
    }

    public func composed<X>(with f: Map<X, Domain>) -> Map<X, Codomain> {
        return Map<X, Codomain> { x in self.applied(to: f.applied(to: x) ) }
    }

    public static func ∘<X>(g: Map<Domain, Codomain>, f: Map<X, Domain>) -> Map<X, Codomain> {
        return g.composed(with: f)
    }
}

public protocol EndType: MapType where Domain == Codomain {
    static var identity: Self { get }
    func composed(with f: Self) -> Self
    static func ∘(g: Self, f: Self) -> Self
}

public extension EndType {
    public static var identity: Self {
        return Self{ x in x }
    }

// MEMO: these causes EXC_BAD_ACCESS for some reason...
//
//    public func composed(with g: Self) -> Self {
//        return Self { x in self.applied(to: g.applied(to: x)) }
//    }
//
//    public static func ∘(g: Self, f: Self) -> Self {
//        return g.composed(with: f)
//    }
}

public typealias End<Domain: SetType> = Map<Domain, Domain>
extension End: EndType where Domain == Codomain { }

//public extension Array where Element: EndType {
//    func composed() -> Element {
//        return self.reduce(Element.identity) {
//            (res, f) in res.composed(with: f)
//        }
//    }
//}

public protocol AutType: SubsetType, EndType, Group where Super: EndType, Domain == Super.Domain {}

public extension AutType {
    public static func *(g: Self, f: Self) -> Self {
        return g.composed(with: f)
    }

    public static func == (a: Self, b: Self) -> Bool {
        return a.asSuper == b.asSuper
    }

    public var hashValue: Int {
        return asSuper.hashValue
    }

    public var description: String {
        return asSuper.description
    }
}

public struct Aut<Domain: SetType>: AutType {
    public typealias Codomain = Domain
    public typealias Super = End<Domain>

    private let map: End<Domain>
    public init(_ map: Map<Domain, Domain>) {
        self.map = map
    }

    public init(_ fnc: @escaping (Domain) -> Domain) {
        self.init(End(fnc))
    }

    public var asSuper: End<Domain> {
        return map
    }

    public static func contains(_ g: Map<Domain, Domain>) -> Bool {
        fatalError()
    }

    public var inverse: Aut<Domain> {
        fatalError()
    }

    public func applied(to x: Domain) -> Domain {
        return map.fnc(x)
    }

    public func composed(with f: Aut<Domain>) -> Aut<Domain> {
        return Aut( { x in self.applied(to: f.applied(to: x)) } )
    }

    public static func ∘ (g: Aut<Domain>, f: Aut<Domain>) -> Aut<Domain> {
        return g.composed(with: f)
    }
}
