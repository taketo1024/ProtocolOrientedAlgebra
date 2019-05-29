import Foundation

public typealias 𝐑 = Double

extension Double: Field, NormedSpace {
    public init(from x: 𝐙) {
        self.init(x)
    }
    
    public init(from r: 𝐐) {
        self.init(r)
    }
    
    public init(_ r: 𝐐) {
        self.init(Double(r.p) / Double(r.q))
    }
    
    public static var zero: 𝐑 {
        return 0
    }
    
    public var sign: 𝐙 {
        return (self >  0) ? 1 :
               (self == 0) ? 0 :
                             -1
    }
    
    public var abs: 𝐑 {
        return 𝐑(Swift.abs(self))
    }
    
    public var norm: 𝐑 {
        return abs
    }
    
    public var inverse: 𝐑? {
        return (self == 0) ? nil : 1/self
    }
    
    public var sqrt: 𝐑 {
        return squareRoot()
    }
    
    public static prefix func √(x: 𝐑) -> 𝐑 {
        return x.sqrt
    }
    
    public func isApproximatelyEqualTo(_ x: 𝐑, error: 𝐑? = nil) -> Bool {
        return (self - x).abs <= (error ?? max(self.ulp, x.ulp))
    }
    
    public static var symbol: String {
        return "𝐑"
    }
}

public let π = 𝐑(Double.pi)
