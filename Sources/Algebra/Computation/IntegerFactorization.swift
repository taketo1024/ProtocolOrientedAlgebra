//
//  IntegerFactorization.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

private var primes: [𝐙] = []

public func primes(upTo n: 𝐙) -> [𝐙] {
    if let last = primes.last, n <= last {
        return primes.filter{ $0 <= n }
    }

    var result: [𝐙] = []
    var seive = primes + Array( (primes.last ?? 1) + 1 ... n.abs )

    while let a = seive.first {
        seive = seive.filter{ $0 % a > 0 }
        result.append(a)
    }

    primes = result
    return result
}

public extension 𝐙 {
    public var divisors: [𝐙] {
        if self == 0 {
            return []
        }

        var result: [𝐙] = []

        let a = self.abs
        let m = Int(sqrt(Double(a)))

        for d in 1...m {
            if a % d == 0 {
                result.append(d)
                result.append(a/d)
            }
        }

        return result.sorted()
    }

    public var primeFactors: [𝐙] {
        var result: [𝐙] = []
        var q = self

        let ps = primes(upTo: self)
        for p in ps {
            while q % p == 0 {
                q /= p
                result.append(p)
            }
        }

        return result
    }
}
