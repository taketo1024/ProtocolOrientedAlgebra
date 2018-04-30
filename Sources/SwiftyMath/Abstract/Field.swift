
public protocol Field: EuclideanRing {
    init(from r: 𝐐)
}

public extension Field {
    public init(from r: 𝐐) {
        fatalError("TODO")
    }

    public var normalizeUnit: Self {
        return self.inverse!
    }

    public var degree: Int {
        return self == .zero ? 0 : 1
    }

    public func eucDiv(by b: Self) -> (q: Self, r: Self) {
        return (self / b, .zero)
    }

    public static func / (a: Self, b: Self) -> Self {
        return a * b.inverse!
    }

    public static var isField: Bool {
        return true
    }
}

public protocol Subfield: Field, Subring {}

public protocol FieldHomType: RingHomType where Domain: Field, Codomain: Field {}

public typealias FieldHom<Domain: Field, Codomain: Field> = Map<Domain, Codomain>
extension FieldHom: FieldHomType where Domain: Field, Codomain: Field {}
