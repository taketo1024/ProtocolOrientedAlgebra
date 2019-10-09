//
//  Dictionary.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public extension Dictionary {
    init<S: Sequence>(pairs: S) where S.Element == (Key, Value) {
        self.init(uniqueKeysWithValues: pairs)
    }
    
    init<S: Sequence>(keys: S, generator: (Key) -> Value) where S.Element == Key {
        self.init(pairs: keys.map{ ($0, generator($0))} )
    }
    
    func contains(key: Key) -> Bool {
        self[key] != nil
    }
    
    func mapKeys<K>(_ transform: (Key) -> K) -> [K : Value] {
        Dictionary<K, Value>(pairs: self.map{ (k, v) in (transform(k), v) })
    }
    
    func mapPairs<K, V>(_ transform: (Key, Value) -> (K, V)) -> [K : V] {
        Dictionary<K, V>(pairs: self.map{ (k, v) in transform(k, v) })
    }
    
    func exclude(_ isExcluded: (Element) throws -> Bool) rethrows -> Dictionary {
        try self.filter{ try !isExcluded($0) }
    }
    
    func replaced(at k: Key, with v: Value) -> Dictionary {
        var a = self
        a[k] = v
        return a
    }
    
    mutating func merge(_ other: Dictionary, overwrite: Bool = false) {
        self.merge(other, uniquingKeysWith: { (v1, v2) in !overwrite ? v1 : v2 })
    }
    
    func merging(_ other: Dictionary, overwrite: Bool = false) -> Dictionary {
        self.merging(other, uniquingKeysWith: { (v1, v2) in !overwrite ? v1 : v2 })
    }
    
    mutating func swap(_ k1: Key, _ k2: Key) {
        let v1 = self[k1]
        self[k1] = self[k2]
        self[k2] = v1
    }
    
    static func + (a: Dictionary, b: Dictionary) -> Dictionary {
        a.merging(b)
    }
}

public extension Dictionary where Value: Hashable {
    var inverse: [Value : Key]? {
        values.isUnique ? Dictionary<Value, Key>(pairs: self.map{(k, v) in (v, k)}) : nil
    }
}
