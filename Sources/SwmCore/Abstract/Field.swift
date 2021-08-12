public protocol Field: EuclideanRing where EuclideanDegreeType == Int {}

public extension Field {
    @inlinable
    var normalizingUnit: Self {
        self.inverse ?? .identity
    }
    
    @inlinable
    var euclideanDegree: Int {
        isZero ? 0 : 1
    }
    
    @inlinable
    static func /%(a: Self, b: Self) -> (quotient: Self, remainder: Self) {
        (a / b, .zero)
    }
    
    @inlinable
    static func / (a: Self, b: Self) -> Self {
        a * b.inverse!
    }
    
    @inlinable
    static var isField: Bool {
        true
    }
}

public protocol Subfield: Field, Subring {}
