//
//  KhHomology.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import SwiftyMath

public extension Link {
    public func khHomology<R: EuclideanRing>(_ type: R.Type) -> KhHomology<R> {
        return KhHomology<R>(self)
    }

    public func khHomology<R: EuclideanRing & Codable>(_ type: R.Type) -> KhHomology<R> {
        let id = "Kh_\(name)_\(R.symbol)"
        return Storage.useCache(id) { KhHomology<R>(self) }
    }
}

public struct KhHomology<R: EuclideanRing> {
    public typealias Inner = Cohomology<KhTensorElement, R>
    public typealias Summand = Inner.Summand

    public let link: Link

    internal let cube: KhCube
    internal let H: Inner

    public init(_ link: Link) {
        self.link = link

        let name = "Kh(\(link.name); \(R.symbol))"
        let (cube, C) = link.KhChainComplex(R.self)

        self.cube = cube
        self.H = Cohomology(name: name, chainComplex: C)
    }

    public subscript(i: Int) -> Summand {
        return H[i]
    }

    public subscript(i: Int, j: Int) -> Summand {
        let s = self[i]
        let filtered = s.summands.enumerated().compactMap{ (k, s) in
            (s.degree == j) ? k : nil
        }

        return s.subSummands(indices: filtered)
    }

    public var offset: Int {
        return H.offset
    }

    public var topDegree: Int {
        return H.topDegree
    }

    public var validDegrees: [(Int, Int)] {
        return (H.offset ... H.topDegree).flatMap { i in
            self[i].summands.map{ $0.generator.degree }.unique().sorted().map{ j in (i, j) }
        }
    }

    public var isHThin: Bool {
        let degs = validDegrees
        if degs.isEmpty { return true }

        let (i0, j0) = (degs.map{ $0.0 }.min()!, degs.map{ $0.1 }.min()!)
        return degs.forAll { (i, j) -> Bool in
            (j == 2 * (i - i0) + j0) || (j == 2 * (i - i0 + 1) + j0)
        }
    }

    public var eulerCharacteristic: Int {
        return H.eulerCharacteristic
    }

    public var gradedEulerCharacteristic: LaurentPolynomial<R> {
        return H.gradedEulerCharacteristic
    }

    public var asCode: String {
        return validDegrees.map{ (i, j) in
            let s = self[i, j]
            let f = (s.rank > 0) ? "0\(Format.sup(s.rank))₍\(Format.sub(i)),\(Format.sub(j))₎" : ""
            let t = s.torsionCoeffs.countMultiplicities().map{ (d, r) in
                "\(d)\(Format.sup(r))₍\(Format.sub(i)),\(Format.sub(j))₎"
            }.joined()
            return f + t
        }.joined()
    }

    public func printTable(detail: Bool = false) {
        let cols = (offset ... topDegree).toArray()
        let degs = cols.flatMap{ i in self[i].summands.map{ $0.degree} }.unique()

        guard let j0 = degs.min(), let j1 = degs.max() else {
            return
        }

        let rows = (j0 ... j1).filter{ ($0 - j0).isEven }.reversed().toArray()
        Format.printTable("j\\i", rows: rows, cols: cols) { (j, i) -> String in
            let s = self[i, j]
            return s.isTrivial ? "" : "\(s)"
        }

        if detail {
            for (i, j) in validDegrees {
                print((i, j))
                for s in self[i, j].summands {
                    print("\t", s, "\t", s.generator)
                }
                print()
            }
        }
    }

    public func KhLee(_ i: Int, _ j: Int) -> (AbstractSimpleModuleStructure<R>, AbstractSimpleModuleStructure<𝐙₂>)? {
        let (prev, this, next) = (self[i - 1, j - 4], self[i, j], self[i + 1, j + 4])

//        print((i, j))
//        print(prev, "\t->\t[", this, "]\t->\t", next, "\n")

        func matrix(from: Summand, to: Summand) -> Matrix<R> {
            let (μL, ΔL) = (KhBasisElement.μL, KhBasisElement.ΔL)
            let grid = from.generators.flatMap { x -> [R] in
                let y = cube.map(x, μL, ΔL)
                return to.factorize(y)
            }
            return Matrix(rows: from.generators.count, cols: to.generators.count, grid: grid).transposed
        }

        func eliminate(from: Summand, to: Summand, matrix A: Matrix<R>) -> (Matrix<R>.EliminationResult, Matrix<𝐙₂>.EliminationResult)? {
            let a1 = from.torsionCoeffs.count
            let a2 = to.torsionCoeffs.count

            guard A.submatrix(a2 ..< A.rows, 0 ..< a1).isZero else {
                print((i, j), ": undecidable")
                return nil
            }

            var B = A.submatrix(a2 ..< A.rows, a1 ..< A.cols) // freePart
            let C = A.submatrix(0 ..< a2, 0 ..< a1)           // torsionPart

            guard C.isZero || (R.self == 𝐙.self && (from.torsionCoeffs + to.torsionCoeffs).forAll{ $0 == R(from: 2) }) else {
                print((i, j), ": only 𝐙 with order-2 torsions are computable.", A)
                return nil
            }

            var C2 = C.mapValues{ 𝐙₂(from: $0 as! 𝐙)}

            let X =  B.eliminate(form: .Smith)
            let Y = C2.eliminate(form: .Smith)

            return (X, Y)
        }

        let Ain  = matrix(from: prev, to: this)
        let Aout = matrix(from: this, to: next)

//        print("In: \n",  Ain.asDynamicMatrix().detailDescription, "\n")
//        print("Out:\n", Aout.asDynamicMatrix().detailDescription, "\n")

        guard let Ein  = eliminate(from: prev, to: this, matrix: Ain),
              let Eout = eliminate(from: this, to: next, matrix: Aout) else {
                return nil
        }

        let S1 = SimpleModuleStructure(
            basis:            this.summands.enumerated().filter{ $0.1.isFree }.map{ AbstractBasisElement($0.0) },
            generatingMatrix: Eout.0.kernelMatrix,
            relationMatrix:   Ein.0.imageMatrix,
            transitionMatrix: Eout.0.kernelTransitionMatrix
        )

        let S2 = SimpleModuleStructure(
            basis:            this.summands.enumerated().filter{ !$0.1.isFree }.map{ AbstractBasisElement($0.0) },
            generatingMatrix: Eout.1.kernelMatrix,
            relationMatrix:   Ein.1.imageMatrix,
            transitionMatrix: Eout.1.kernelTransitionMatrix
        )

        return (S1, S2)
    }

    public func printKhLeeTable() {
        let cols = (offset ... topDegree).toArray()
        let degs = cols.flatMap{ i in self[i].summands.map{ $0.degree } }.unique()

        guard let j0 = degs.min(), let j1 = degs.max() else {
            return
        }

        let rows = (j0 ... j1).filter{ ($0 - j0).isEven }.reversed().toArray()
        Format.printTable("j\\i", rows: rows, cols: cols) { (j, i) -> String in
            let s = self.KhLee(i, j)
            return s.flatMap{ (s1, s2) in
                switch (s1.isTrivial, s2.isTrivial) {
                case (true , true ): return ""
                case (false, true ): return s1.description
                case (true , false): return s2.description
                default            : return s1.description + "⊕" + s2.description
                }
            } ?? "?"
        }
    }
}

extension KhHomology: Codable where R: Codable {
    enum CodingKeys: String, CodingKey {
        case link, H
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.link = try c.decode(Link.self, forKey: .link)
        self.cube = KhCube(link)
        self.H = try c.decode(Inner.self, forKey: .H)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(link, forKey: .link)
        try c.encode(H, forKey: .H)
    }
}
