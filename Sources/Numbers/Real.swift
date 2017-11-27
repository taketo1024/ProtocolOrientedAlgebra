import Foundation

public typealias RealNumber = Double

extension RealNumber: Field {
    public init(intValue n: IntegerNumber) {
        self.init(n)
    }

    public var inverse: RealNumber? {
        return (self != 0) ? 1 / self : nil
    }

    public static var symbol: String {
        return "R"
    }
}
