//
//  BernoulliNumbers.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

private var B: [𝐐] = [1]

// see: https://en.wikipedia.org/wiki/Bernoulli_number#Recursive_definition
public func BernoulliNumber(_ n: Int) -> 𝐐 {
    if n < B.count {
        return B[n]
    }

    if n > 1 && n % 2 == 1 && B.count == n - 1 {
        B.append(0)
        return 0
    }

    let b = (0 ..< n).sum { k in
        -𝐐(n.factorial, k.factorial * (n - k).factorial * (n - k + 1)) * BernoulliNumber(k)
    }
    B.append(b)

    return b
}
