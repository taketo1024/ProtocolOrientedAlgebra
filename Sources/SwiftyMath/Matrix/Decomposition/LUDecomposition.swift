//
//  LUDecomposition.swift
//  
//
//  Created by Taketo Sano on 2021/05/13.
//

public struct LUDecomposition<Impl: MatrixImpl_LU, n: SizeType, m: SizeType> {
    public typealias Matrix    = MatrixInterface<Impl, n, m>
    public typealias LeftPerm  = MatrixInterface<Impl, n, n>
    public typealias RightPerm = MatrixInterface<Impl, m, m>
    public typealias MatrixL   = MatrixInterface<Impl, n, DynamicSize>
    public typealias MatrixU   = MatrixInterface<Impl, DynamicSize, m>
    public typealias Image     = MatrixInterface<Impl, n, DynamicSize>
    public typealias Kernel    = MatrixInterface<Impl, m, DynamicSize>

    public let impl: Impl
    
    public init(_ impl: Impl) {
        self.impl = impl
    }
    
    public var L: MatrixL {
        .init(impl.L)
    }
    
    public var U: MatrixU {
        .init(impl.U)
    }
    
    public var P: LeftPerm {
        .init(impl.P)
    }

    public var Q: RightPerm {
        .init(impl.Q)
    }
    
    public var LU: (MatrixL, MatrixU) {
        (L, U)
    }
    
    public var PQ: (LeftPerm, RightPerm) {
        (P, Q)
    }
    
    public var rank: Int {
        impl.rank
    }
    
    public var nullity: Int {
        impl.nullity
    }
    
    public var image: Image {
        .init(impl.image)
    }
    
    public var kernel: Kernel {
        .init(impl.kernel)
    }
    
    public func solve(_ b: MatrixInterface<Impl, n, _1>) -> MatrixInterface<Impl, m, _1>? {
        impl.solve(b.impl).flatMap{ .init($0) }
    }
}

public protocol MatrixImpl_LU: MatrixImpl {
    var L: Self { get }
    var U: Self { get }
    var P: Self { get }
    var Q: Self { get }
    var rank: Int { get }
    var nullity: Int { get }
    var image: Self { get }
    var kernel: Self { get }
    func solve(_ b: Self) -> Self?
}

extension MatrixInterface where Impl: MatrixImpl_LU {
    public func luDecomposition() -> LUDecomposition<Impl, n, m> {
        LUDecomposition(impl)
    }
}
