public typealias RealNumber = Double
public typealias 𝐑 = RealNumber

public let π = 𝐑(Double.pi)

extension RealNumber: Field {
    public init(from x: 𝐙) {
        self.init(x)
    }
    
    public init(from r: 𝐐) {
        self.init(r)
    }
    
    public init(_ r: 𝐐) {
        self.init(Double(r.numerator) / Double(r.denominator))
    }
    
    public static var zero: 𝐑 {
        0
    }
    
    public var sign: 𝐙 {
        (self >  0) ? 1 :
        (self == 0) ? 0 :
                     -1
    }
    
    public var abs: 𝐑 {
        .init(Swift.abs(self))
    }
    
    public var inverse: 𝐑? {
        (self == 0) ? nil : 1/self
    }
    
    public var sqrt: 𝐑 {
        squareRoot()
    }
    
    public static prefix func √(x: 𝐑) -> 𝐑 {
        x.sqrt
    }
    
    public func isApproximatelyEqualTo(_ x: 𝐑, error: 𝐑? = nil) -> Bool {
        (self - x).abs <= (error ?? max(self.ulp, x.ulp))
    }
    
    public static var symbol: String {
        "𝐑"
    }
}

extension 𝐑: Randomable, RangeRandomable {
    public static func random() -> Self {
        // MEMO:
        // random(in: -greatestFiniteMagnitude ..< greatestFiniteMagnitude)
        // throws fatalError.
        Bool.random() ? random(in: 0 ..< greatestFiniteMagnitude) : -random(in: 0 ..< greatestFiniteMagnitude)
    }
}

extension 𝐑: ComplexSubset {
    public var asComplex: 𝐂 {
        .init(self)
    }
}

public protocol RealSubset {
    var asReal: 𝐑 { get }
}
