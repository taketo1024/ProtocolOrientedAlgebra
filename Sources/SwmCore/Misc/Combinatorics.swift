//
//  Combinatorics.swift
//  Sample
//
//  Created by Taketo Sano on 2019/10/04.
//

public extension Sequence {
    var permutations: [[Element]] {
        // MEMO Heap's algorithm: https://en.wikipedia.org/wiki/Heap%27s_algorithm
        
        var result: [[Element]] = []
        var arr = Array(self)

        func generate(_ k: Int) {
            if k == 1 {
                result.append(arr)
            } else {
                generate(k - 1)
                for i in 0 ..< k - 1 {
                    let swap = k.isEven ? (i, k - 1) : (0, k - 1)
                    arr.swapAt(swap.0, swap.1)
                    generate(k - 1)
                }
            }
        }

        generate(arr.count)
        
        return result
    }
    
    func choose(_ k: Int) -> [[Element]] {
        ArraySlice(self).choose(k)
    }

    func multiChoose(_ k: Int) -> [[Element]] {
        ArraySlice(self).multiChoose(k)
    }
}

public extension ArraySlice {
    func choose(_ k: Int) -> [[Element]] {
        assert(k >= 0)
        
        let n = count
        
        if k == 0 {
            return [[]]
        } else if n < k {
            return []
        } else {
            let last = self.last!
            let sliced = self[0 ..< (n - 1)]
            return sliced.choose(k) + sliced.choose(k - 1).map{ $0.appended(last) }
        }
    }
    
    func multiChoose(_ k: Int) -> [[Element]] {
        assert(k >= 0)
        
        let n = count
        
        if k == 0  {
            return [[]]
        } else if n == 0 {
            return []
        } else {
            return (0 ... k).flatMap { (i: Int) -> [[Element]] in
                let last = self.last!
                let sliced = self[0 ..< n - 1]
                return sliced.multiChoose(k - i).map{ (sub: [Element]) -> [Element] in
                    sub.filled(with: last, upToLength: k)
                }
            }
        }
    }
}
