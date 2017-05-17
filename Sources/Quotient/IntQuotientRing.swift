import Foundation

public protocol IntQuotientType: EuclideanQuotientRing {
    associatedtype R = IntegerNumber
}

public struct IntQuotientRing<n: _Int>: IntQuotientType {
    public typealias R = IntegerNumber
    
    public let value: Int
    
    // root initializer
    public init(_ value: R) {
        self.value = (value % n.value)
    }
    
    public var mod: Int {
        return n.value
    }
    
    public static var symbol: String {
        return "Z/\(n.value)"
    }
}

public struct IntQuotientField<p: _Int>: IntQuotientType, EuclideanQuotientField {
    public typealias R = IntegerNumber
    
    public let value: Int
    
    public init(_ value: R) {
        self.value = value
        
        // TODO check if p is prime.
    }
    
    public var mod: Int {
        return p.value
    }
    
    public var inverse: IntQuotientField<p> {
        let (x, _, _) = bezout(value, mod)
        return IntQuotientField(x)
    }
    
    public static var symbol: String {
        return "Z/\(p.value)"
    }
}
