//
//  Array.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/07.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension Array {
    func binarySearch<T: Comparable>(_ needle: T, _ indexer: (Element) -> T) -> (index: Int, element: Element)? {
        var l = 0
        var u = self.count - 1

        while l <= u {
            let i = (l + u) / 2
            let a = self[i]
            let x = indexer(a)

            if(needle == x) {
                return (i, a)
            } else {
                if (needle < x) {
                    u = i - 1
                } else {
                    l = i + 1
                }
            }
        }
        return nil
    }
}
