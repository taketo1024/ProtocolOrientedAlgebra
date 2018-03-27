//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra
import SwiftyTopology

// Coeff Ring
typealias R = 𝐙
//typealias R = 𝐙₂
//typealias R = 𝐐

do {
    let n = 2
    let X = SimplicialComplex.torus(dim: n)
    let s = X.cells(ofDim: n)[0]

    let A = (X - s).named("A")
    let B = s.asComplex.named("B")

    var E = HomologyExactSequence.MayerVietoris(X, A, B, R.self)

    E.fill(column: 0)
    E.fill(column: 1)

    print("2) \(E.H2)\n")
    print(E.detailDescription, "\n")

    E.solve(debug: true)

    print("\nresult:")
    print(E.detailDescription, "\n\n")
}

do {
    let n = 2
    let D = SimplicialComplex.ball(dim: n)
    let S = D.boundary.named("S^\(n-1)")
    var E = CohomologyExactSequence(D, S, R.self)

    E.fill(column: 0)
    E.fill(column: 1)

    print("3) \(E.H2)\n")
    print(E.detailDescription, "\n")

    E.solve(debug: true)

    print("\nresult:")
    print(E.detailDescription, "\n\n")
}

do {
    let n = 2
    let X = SimplicialComplex.realProjectiveSpace(dim: n)
    let s = X.cells(ofDim: n)[0]

    let A = (X - s).named("A")
    let B = s.asComplex.named("B")

    var E = CohomologyExactSequence.MayerVietoris(X, A, B, R.self)

    E.fill(column: 1)
    E.fill(column: 2)

    print("4) \(E.H2)\n")
    print(E.detailDescription, "\n")

    E.solve(debug: true)

    print("\nresult:")
    print(E.detailDescription, "\n\n")
}
