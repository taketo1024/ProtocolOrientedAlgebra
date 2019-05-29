import Foundation

public protocol Field: EuclideanRing {
    init(from r: 𝐐)
}

public extension Field {
    init(from r: 𝐐) {
        fatalError("TODO")
    }
    
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
