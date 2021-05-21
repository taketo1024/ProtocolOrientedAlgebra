import SwiftyMath

// MARK: Integers

do {
    typealias Z = 𝐙 // == Int
    
    let a = 7
    let b = 3

    a + b
    a - b
    a * b
    b % a
}

// MARK: Rational Numbers

do {
    typealias Q = 𝐐
    
    let a = 4 ./ 5  // 4/5
    let b = 3 ./ 2  // 3/2

    a + b
    a - b
    a * b
    a / b
}

// MARK: Real Numbers (actually not)

do {
    typealias R = 𝐑 // == Double
    
    let a = 2.0
    let b = -4.5

    a + b
    a - b
    a * b
    a / b
    √a
}

// MARK: ComplexNumbers

do {
    typealias C = 𝐂 // == Complex<𝐑>
    
    let i: C = .imaginaryUnit
    
    i * i == -1
    
    let a: C = 3 + i
    let b: C = 4 + 2 * i

    a + b
    a - b
    a * b
    
    i.inverse
    a.inverse
    b.inverse
    
    a / b
    
    let π = C(.pi)
    exp(i * π).isApproximatelyEqualTo(-1, error: 0.000001)
}

do {
    typealias C = Complex<𝐙> // Gaussian integers 𝐙[i]
    
    let i: C = .imaginaryUnit
    let a: C = 3 + i
    let b: C = 4 + 2 * i

    a + b
    a - b
    a * b
    
    i.inverse
    a.inverse
    b.inverse
    
//  a / b  // this is not available, since 𝐙 is not a field.
}

// MARK: Quaternions

do {
    typealias H = 𝐇 // == Quaternion<𝐑>
    
    let i: H = .i
    let j: H = .j
    let k: H = .k

    i * i == -1
    j * j == -1
    k * k == -1
    
    i * j == k
    j * k == i
    k * i == j

    let a: H = 1 + 2 * i
    let b: H = 3 - 2 * j

    a + b
    a - b
    a * b
    
    i.inverse
    a.inverse
    b.inverse
    
    a / b
}


// MARK: IntegerQuotients

do {
    typealias Z3 = IntegerQuotientRing<_3> // this a field
    
    let a: Z3 = 2
    let b: Z3 = 1
    
    a + b
    a - b
    a * b
    
    a.inverse
    b.inverse
    
    b / a
}

do {
    typealias Z4 = IntegerQuotientRing<_4> // this not a field
    
    let a: Z4 = 2
    let b: Z4 = 1
    
    a + b
    a - b
    a * b
    
    a.inverse
    b.inverse
    
//  a / b // this is unavailable, since 4 is not a prime.
}

// MARK: Algebraic extension

do {
    typealias P = Polynomial<𝐐, StandardPolynomialIndeterminates.x>
    struct p: IrrPolynomialTP {
        static let value = P(coeffs: -2, 0, 1) // x^2 - 2
    }
    typealias A = PolynomialQuotientRing<P, p> // 𝐐[x]/(x^2 - 2) = 𝐐(√2)
    
    let x = A(.indeterminate)  // x ∈ 𝐐[x]/(x^2 - 2)
    x * x == 2                 // x = √2
    
    x.isInvertible
    x.inverse
    
    x * x.inverse! == 1
    
    let a: A = 1 + x
    let b: A = 2 - x
    
    a + b
    a - b
    a * b
    a / b
}
