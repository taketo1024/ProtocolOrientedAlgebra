import Foundation

public struct FreeModuleHom<A: FreeModuleBase, B: FreeModuleBase, R: Ring>: ModuleHom {
    public typealias CoeffRing = R
    public typealias Domain = FreeModule<A, R>
    public typealias Codomain = FreeModule<B, R>

    private let map: (A) -> [(B, R)]

    public init(_ f: @escaping (A) -> [(B, R)]) {
        self.map = f
    }

    public init<n, m>(from: [A], to: [B], matrix: Matrix<n, m, R>) {
        self.map = { a in
            guard let j = from.index(of: a) else {
                return []
            }
            return zip(to, matrix.colArray(j)).toArray()
        }
    }

    public func appliedTo(_ a: A) -> Codomain {
        return Codomain(map(a))
    }

    public func appliedTo(_ m: Domain) -> Codomain {
        var d: [B : R] = [:]
        for (a, r) in m {
            for (b, s) in self.appliedTo(a) {
                d[b] = d[b, default: .zero] + r * s
            }
        }
        return Codomain(d)
    }

    public static var zero: FreeModuleHom<A, B, R> {
        return FreeModuleHom { _ in [] }
    }

    public static var identity: FreeModuleHom<A, A, R> {
        return FreeModuleHom<A, A, R> { a in [(a, .identity)] }
    }

    public static func ==(lhs: FreeModuleHom<A, B, R>, rhs: FreeModuleHom<A, B, R>) -> Bool {
        fatalError("FreeModuleHom.== is unavailable.")
    }

    public static func +(f: FreeModuleHom<A, B, R>, g: FreeModuleHom<A, B, R>) -> FreeModuleHom<A, B, R> {
        return FreeModuleHom { a in
            (f.appliedTo(a) + g.appliedTo(a)).map{ ($0, $1) }
        }
    }

    public prefix static func -(f: FreeModuleHom<A, B, R>) -> FreeModuleHom<A, B, R> {
        return FreeModuleHom { a in f.map(a).map{ (a, r) in (a, -r)} }
    }

    public static func *(r: R, f: FreeModuleHom<A, B, R>) -> FreeModuleHom<A, B, R> {
        return FreeModuleHom { a in f.map(a).map{ (a, s) in (a, r * s)} }
    }

    public static func *(f: FreeModuleHom<A, B, R>, r: R) -> FreeModuleHom<A, B, R> {
        return FreeModuleHom { a in f.map(a).map{ (a, s) in (a, s * r)} }
    }

    public static func ∘<C>(g: FreeModuleHom<B, C, R>, f: FreeModuleHom<A, B, R>) -> FreeModuleHom<A, C, R> {
        return FreeModuleHom<A, C, R> { a -> [(C, R)] in
            (g.appliedTo(f.appliedTo(a))).map{ ($0, $1) }
        }
    }

    public static func ⊗<C, D>(f: FreeModuleHom<A, B, R>, g: FreeModuleHom<C, D, R>) -> FreeModuleHom<Tensor<A, C>, Tensor<B, D>, R> {
        return FreeModuleHom<Tensor<A, C>, Tensor<B, D>, R> { t in
            let (a, b) = (t._1, t._2)
            return (f.appliedTo(a) ⊗ g.appliedTo(b)).map{ ($0, $1) }
        }
    }

    public var hashValue: Int {
        return 0 // TODO
    }
}
