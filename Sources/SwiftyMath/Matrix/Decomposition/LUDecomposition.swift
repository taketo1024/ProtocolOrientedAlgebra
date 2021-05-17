//
//  LUDecomposition.swift
//  
//
//  Created by Taketo Sano on 2021/05/13.
//

public struct LUDecomposition<Impl: MatrixImpl_LU, n: SizeType, m: SizeType> {
    public typealias Matrix<n, m> = MatrixInterface<Impl, n, m> where n: SizeType, m: SizeType
    public typealias MatrixL = Matrix<n, DynamicSize>
    public typealias MatrixU = Matrix<DynamicSize, m>
    public typealias CodomainSub = Matrix<n, DynamicSize>
    public typealias DomainSub   = Matrix<m, DynamicSize>
    public typealias LeftPermutation  = Permutation<n>
    public typealias RightPermutation = Permutation<m>

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
        impl.P.as(LeftPermutation.self)
    }

    public var rightPermutation: RightPermutation {
        impl.Q.as(RightPermutation.self)
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
        let Q = rightPermutation.asMatrix(Impl.self)
        return Matrix(Q).submatrix(colRange: 0 ..< r)
    }
    
    // Coker(f) := W / Im(f)
    public var cokernel: CodomainSub {
        // Im(A) = Im(P^-1 L U Q^-1) = Im(P^-1 L).
        //   -> complement: Im(P^-1 [O; I_{n-r}])
        
        let (n, r) = (impl.size.rows, rank)
        let Pinv = leftPermutation.inverse!.asMatrix(Impl.self)
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
    var P: Permutation<DynamicSize> { get }
    var Q: Permutation<DynamicSize> { get }
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
