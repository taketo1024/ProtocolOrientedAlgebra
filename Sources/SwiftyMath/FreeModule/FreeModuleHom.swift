
// MEMO: with parametrized extension, replace:
// public typealias FreeModuleHom<A, B, R> = Map<FreeModule<A, R>, FreeModule<A, R>>

public struct FreeModuleHom<A: BasisElementType, B: BasisElementType, R: Ring>: ModuleHomType {
    public typealias CoeffRing = R
    public typealias Domain    = FreeModule<A, R>
    public typealias Codomain  = FreeModule<B, R>

    private let f: (Domain) -> Codomain
    public init(_ f: @escaping (Domain) -> Codomain) {
        self.f = f
    }

    // MEMO: determined by the image of the basis.
    public init(_ f: @escaping (A) -> Codomain) {
        self.init { (m: Domain) in
            var d: [B : R] = [:]
            for (a, r) in m {
                for (b, s) in f(a) {
                    d[b] = d[b, default: .zero] + r * s
                }
            }
            return Codomain(d)
        }
    }

    public init<n, m>(from: [A], to: [B], matrix: _Matrix<n, m, R>) {
        assert(from.count == matrix.cols)
        assert(  to.count == matrix.rows)

        self.init { (a: A) -> Codomain in
            guard let j = from.index(of: a) else {
                return .zero
            }
            return Codomain(basis: to, vector: matrix.colVector(j))
        }
    }

    public func asMatrix(from: [A], to: [B]) -> Matrix<CoeffRing> {
        let comps = from.enumerated().flatMap { (j, a) -> [MatrixComponent<CoeffRing>] in
            let w = self.applied(to: a)
            return w.factorize(by: to).enumerated().map { (i, a) in MatrixComponent(i, j, a) }
        }
        return Matrix(rows: to.count, cols: from.count, components: comps)
    }

    public func applied(to a: A) -> Codomain {
        return applied(to: FreeModule(a))
    }

    public func applied(to m: Domain) -> Codomain {
        return f(m)
    }

    public func composed<X>(with f: FreeModuleHom<X, A, R>) -> FreeModuleHom<X, B, R> {
        return FreeModuleHom<X, B, R> { (x: X) in
            self.applied(to: f.applied(to: x))
        }
    }

    public static func ∘<C>(g: FreeModuleHom<B, C, R>, f: FreeModuleHom<A, B, R>) -> FreeModuleHom<A, C, R> {
        return g.composed(with: f)
    }
}

extension FreeModuleHom: EndType where A == B {
    public static var identity: FreeModuleHom<A, B, R> {
        return FreeModuleHom { x in x }
    }
}
