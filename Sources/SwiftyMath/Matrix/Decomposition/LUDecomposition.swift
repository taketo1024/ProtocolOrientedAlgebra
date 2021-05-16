//
//  LUDecomposition.swift
//  
//
//  Created by Taketo Sano on 2021/05/13.
//

public struct LUDecomposition<Impl: MatrixImpl_LU, n: SizeType, m: SizeType> {
    public typealias Matrix    = MatrixInterface<Impl, n, m>
    public typealias MatrixL   = MatrixInterface<Impl, n, DynamicSize>
    public typealias MatrixU   = MatrixInterface<Impl, DynamicSize, m>
    public typealias LeftPermutation  = MatrixInterface<Impl, n, n>
    public typealias RightPermutation = MatrixInterface<Impl, m, m>
    public typealias CodomainSub = MatrixInterface<Impl, n, DynamicSize>
    public typealias DomainSub   = MatrixInterface<Impl, m, DynamicSize>

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
    
    public var leftPermutation: LeftPermutation {
        .init(impl.P)
    }

    public var rightPermutation: RightPermutation {
        .init(impl.Q)
    }
    
    public var rank: Int {
        impl.rank
    }
    
    public var nullity: Int {
        impl.nullity
    }
    
    public var kernel: DomainSub {
        .init(impl.kernel)
    }
    
    public var image: CodomainSub {
        .init(impl.image)
    }
    
    // V / Ker(f) ≅ Im(f)
    public var kernelComplement: DomainSub {
        // A = P^-1 L U Q^-1.
        // Q * [I_r; O] gives the injective part of U.
        
        let r = rank
        let Q = rightPermutation
        return Q.submatrix(colRange: 0 ..< r)
    }
    
    // Coker(f) := W / Im(f)
    public var cokernel: CodomainSub {
        // Im(A) = Im(P^-1 L U Q^-1) = Im(P^-1 L).
        //   -> complement: Im(P^-1 [O; I_{n-r}])
        
        let (n, r) = (impl.size.rows, rank)
        let Pinv = leftPermutation.inverse!
        return Pinv.submatrix(colRange: r ..< n)
    }
    
    public func solve<k>(_ b: MatrixInterface<Impl, n, k>) -> MatrixInterface<Impl, m, k>? {
        assert(impl.size.rows == b.size.rows)
        return impl.solve(b.impl).flatMap{ .init($0) }
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
