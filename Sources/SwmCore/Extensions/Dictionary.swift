//
//  Dictionary.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public extension Dictionary {
    @inlinable
    static var empty: Self {
        [:]
    }

    @inlinable
    init<S: Sequence>(_ pairs: S) where S.Element == (Key, Value) {
        self.init(uniqueKeysWithValues: pairs)
    }
    
    @inlinable
    init<S: Sequence>(keys: S, generator: (Key) -> Value) where S.Element == Key {
        self.init(keys.map{ ($0, generator($0))} )
    }
    
    @inlinable
    func contains(key: Key) -> Bool {
        self[key] != nil
    }
    
    @inlinable
    func mapKeys<K>(_ transform: (Key) -> K) -> [K : Value] {
        Dictionary<K, Value>(self.map{ (k, v) in (transform(k), v) })
    }
    
    @inlinable
    func mapPairs<K, V>(_ transform: (Key, Value) -> (K, V)) -> [K : V] {
        Dictionary<K, V>(self.map{ (k, v) in transform(k, v) })
    }
    
    @inlinable
    func exclude(_ isExcluded: (Element) throws -> Bool) rethrows -> Dictionary {
        try self.filter{ try !isExcluded($0) }
    }
    
    @inlinable
    func replaced(valueForKey k: Key, with v: Value) -> Dictionary {
        var a = self
        a[k] = v
        return a
    }
    
    @inlinable
    mutating func merge(_ other: Dictionary, overwrite: Bool = false) {
        self.merge(other, uniquingKeysWith: { (v1, v2) in !overwrite ? v1 : v2 })
    }
    
    @inlinable
    func merging(_ other: Dictionary, overwrite: Bool = false) -> Dictionary {
        self.merging(other, uniquingKeysWith: { (v1, v2) in !overwrite ? v1 : v2 })
    }
    
    @inlinable
    mutating func swap(_ k1: Key, _ k2: Key) {
        let v1 = self[k1]
        self[k1] = self[k2]
        self[k2] = v1
    }
    
    @inlinable
    static func + (a: Dictionary, b: Dictionary) -> Dictionary {
        a.merging(b)
    }
}

public extension Dictionary where Value: Hashable {
    func invert() -> [Value : Key] {
        Dictionary<Value, Key>(self.map{(k, v) in (v, k)}) { (v1, _) in
            v1
        }
    }
}
