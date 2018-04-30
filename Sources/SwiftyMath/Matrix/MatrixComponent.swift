//
//  MatrixComponent.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/24.
//

public struct MatrixComponent<R: Ring>: Hashable {
    public let row: Int
    public let col: Int
    public let value: R

    public init(_ row: Int, _ col: Int, _ value: R) {
        self.row = row
        self.col = col
        self.value = value
    }
}

extension MatrixComponent: Codable where R: Codable {
    enum CodingKeys: String, CodingKey {
        case row
        case col
        case value
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.row = try c.decode(Int.self, forKey: .row)
        self.col = try c.decode(Int.self, forKey: .col)
        self.value = try c.decode(R.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(row, forKey: .row)
        try c.encode(col, forKey: .col)
        try c.encode(value, forKey: .value)
    }
}
