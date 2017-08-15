# Swifty Algebra

Sample project to explain concepts of [Abstract Algebra](https://en.wikipedia.org/wiki/Abstract_algebra) by implementing in Swift.

## Sample

### Rational Number

```swift
let a = ℚ(4, 5)  // 4/5
let b = ℚ(3, 2)  // 3/2

a + b  // 23/10
a * b  // 6/5
b / a  // 15/8
```

### Matrix (type safe)

```swift
typealias n = TPInt_2
typealias M = Matrix<ℤ, n, n>

let a = M(1, 2, 3, 4)  // [1, 2; 3, 4]
let b = M(2, 1, 1, 2)  // [2, 1; 1, 2]

a + b  // [3, 3; 4, 6]
a * b  // [4, 5; 10, 11]

a + b == b + a  // true: addition is commutative
a * b == b * a  // false: multiplication is noncommutative
```

### Permutation (Symmetric Group)

```swift
typealias 𝔖_5 = Permutation<TPInt_5>

let σ = 𝔖_5(0, 1, 2) // cyclic notation
let τ = 𝔖_5([0: 2, 1: 3, 2: 4, 3: 0, 4: 1]) // two-line notation

σ[1]  // 2
τ[2]  // 4

(σ * τ)[3]  // 3 -> 0 -> 1 
(τ * σ)[3]  // 3 -> 3 -> 0

σ * τ == τ * σ   // false: noncommutative
```

### Polynominal

```swift
typealias ℚx = Polynomial<Q>

let f = ℚx(0, 2, -3, 1) // f(x) = x^3 − 3x^2 + 2x
let g = ℚx(6, -5, 1)    // g(x) = x^2 − 5x + 6
    
f + g  // (f + g)(x) = x^3 - 2x^2 - 3x + 6
f * g  // (f * g)(x) = x^5 - 8x^4 + 23x^3 - 28x^2 + 12x
f % g  // (f % g)(x) = 6x - 12
    
gcd(f, g) // 6x - 12
```

### Integer Quotient (Finite Field)

```swift
struct I: IntIdeal { static let generator = 5 }
typealias ℤ_5 = IntQuotient<I>

let a: ℤ_5 = 2  // 2 mod 5
let b: ℤ_5 = 4  // 4 mod 5
let c: ℤ_5 = 8  // 3 mod 5
    
a + b  // 1 mod 5
a * b  // 3 mod 5
    
typealias 𝔽_5 = IntQuotientField<I>

let x: 𝔽_5 = 2  // 2 mod 5
let y = 1 / x   // 3 mod 5
x * y == 1      // true
```

### Polynominal Quotient (Field Extension)

#### ℚ(√2),  ℚ(√2, √3)

```swift
// g(x) = x^2 - 2 in ℚ[x]
struct g: PolynominalIdeal {
    typealias R = Polynominal<ℚ>
    static let generator = Polynominal<ℚ>(-2, 0, 1)
}

// L = ℚ[x]/(g) = ℚ(√2)
typealias L = PolynominalQuotientField<ℚ, g>  

let α = L(0, 1) // α = √2 in L
α * α == 2      // true

(1 + α) * (1 + α) == 3 + 2 * α  // true: (1 + √2)^2   = 3 + 2√2
1 / (1 + α)       == -1 + α     // true: 1 / (1 + √2) = -1 + √2

// h(x) = x^2 - 3 in L[x]
struct h: PolynominalIdeal {
    typealias R = Polynominal<L>
    static let generator = R(-3, 0, 1)
}
// M = L[x]/(h) = L(√3) = ℚ(√2, √3)
typealias M = PolynominalQuotientField<L, h>  

let β = M(α)      // β = √2 in M
let γ = M(0, 1)   // γ = √3 in M
let δ = β * γ     // δ = √6 in M

β * β == 2        // true
γ * γ == 3        // true
δ * δ == 6        // true

(β + γ) ** 2 == 5 + 2 * δ // true: (√2 + √3)^2 = 5 + 2√6
```

#### ℂ: Complex Number Field

```swift
// g(x) = x^2 + 1 in ℝ[x]
struct g: PolynominalIdeal {
    typealias R = Polynominal<ℝ>
    static let generator = Polynominal<ℝ>(1, 0, 1)
}

// ℂ = ℝ[x]/(x^2 + 1) = ℝ(i)
typealias ℂ = PolynominalQuotient<g>  

let i = ℂ(0, 1)      // i = √-1
i * i == -1          // true
 
let z = 3 + 2 * i    // z = 3 + 2i
z * z == 5 + 12 * i  // true
```

## Guide to Abstract Algebra

1. [数とは何か？](http://qiita.com/taketo1024/items/bd356c59dc0559ee9a0b) 
2. [群・環・体の定義](http://qiita.com/taketo1024/items/733e0ecf12da359db729)
3. [有理数を作ってみよう](http://qiita.com/taketo1024/items/222a6a418fb29a0684f8)
4. [時計の世界の「環」](http://qiita.com/taketo1024/items/91fbc70136b0e5706c09)
5. [小さな「体」を作ろう](http://qiita.com/taketo1024/items/f5cd40bf669fa8511f9b)
6. [多項式は整数によく似てる](http://qiita.com/taketo1024/items/83be0ad7d2f2e4f3f44d)
7. [代数拡大で数を作ろう！](http://qiita.com/taketo1024/items/ccf7ece3dfeb98b38946)

## Used Libraries

1. [Eigen](http://eigen.tuxfamily.org/) 
2. [ole/SortedArray](https://github.com/ole/SortedArray)

## License
**Swifty Algebra** is licensed under [CC0 1.0 Universal](LICENSE).
