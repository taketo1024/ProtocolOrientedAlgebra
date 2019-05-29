import Foundation

public protocol Field: EuclideanRing {}

public extension Field {
    var normalizeUnit: Self {
        return self.inverse!
    }
    
    var eucDegree: Int {
        return self == .zero ? 0 : 1
    }
    
    func eucDiv(by b: Self) -> (q: Self, r: Self) {
        return (self / b, .zero)
    }
    
    static func / (a: Self, b: Self) -> Self {
        return a * b.inverse!
    }
    
    static var isField: Bool {
        return true
    }
}

public protocol Subfield: Field, Subring {}

public typealias AsVectorSpace<R: Field> = AsModule<R>

extension AsVectorSpace: VectorSpace, FiniteDimVectorSpace where R: Field {
    public static var dim: Int {
        return 1
    }
    
    public static var standardBasis: [AsVectorSpace<R>] {
        return [AsVectorSpace(.identity)]
    }
    
    public var standardCoordinates: [R] {
        return [value]
    }
}
