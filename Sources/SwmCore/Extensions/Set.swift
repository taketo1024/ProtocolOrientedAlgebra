//
//  Set.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/25.
//

extension Set {
    public mutating func removeAll(where predicate: (Element) -> Bool) {
        for e in self where predicate(e) {
            remove(e)
        }
    }
}
