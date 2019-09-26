public protocol Field: EuclideanRing {}

public extension Field {
    var normalizingUnit: Self {
        self.inverse ?? .identity
    }
    
    var eucDegree: Int {
        self == .zero ? 0 : 1
    }
    
    func eucDiv(by b: Self) -> (q: Self, r: Self) {
        (self / b, .zero)
    }
    
    static func / (a: Self, b: Self) -> Self {
        a * b.inverse!
    }
    
    static var isField: Bool {
        true
    }
}

public protocol Subfield: Field, Subring {}
