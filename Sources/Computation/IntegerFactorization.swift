//
//  IntegerFactorization.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

private var primes: [IntegerNumber] = []

public func primes(upTo n: IntegerNumber) -> [IntegerNumber] {
    if let last = primes.last, n <= last {
        return primes.filter{ $0 <= n }
    }

    var result: [IntegerNumber] = []
    var seive = primes + Array( (primes.last ?? 1) + 1 ... abs(n) )

    while let a = seive.first {
        seive = seive.filter{ $0 % a > 0 }
        result.append(a)
    }

    primes = result
    return result
}

public extension IntegerNumber {
    public var divisors: [IntegerNumber] {
        if self == 0 {
            return []
        }

        var result: [IntegerNumber] = []

        let a = abs(self)
        let m = Int(sqrt(Double(a)))

        for d in 1...m {
            if a % d == 0 {
                result.append(d)
                result.append(a/d)
            }
        }

        return result.sorted()
    }

    public var primeFactors: [IntegerNumber] {
        var result: [IntegerNumber] = []
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
