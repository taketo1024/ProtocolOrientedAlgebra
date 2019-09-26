public protocol Field: EuclideanRing {}

public extension Field {
    var normalizingUnit: Self {
        self.inverse ?? .identity
    }
    
    var euclideanDegree: Int {
        isZero ? 0 : 1
    }
    
    static func /%(a: Self, b: Self) -> (q: Self, r: Self) {
        (a / b, .zero)
    }
    
    static func / (a: Self, b: Self) -> Self {
        a * b.inverse!
    }
    
    static var isField: Bool {
        true
    }
}

public protocol Subfield: Field, Subring {}
