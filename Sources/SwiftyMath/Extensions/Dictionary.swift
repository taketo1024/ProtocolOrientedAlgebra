//
//  Dictionary.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public extension Dictionary {
    public init<S: Sequence>(pairs: S) where S.Element == (Key, Value) {
        self.init(uniqueKeysWithValues: pairs)
    }
    
    public init<S: Sequence>(keys: S, generator: (Key) -> Value) where S.Element == Key {
        self.init(pairs: keys.map{ ($0, generator($0))} )
    }
    
    public func mapPairs<K, V>(_ transform: (Key, Value) -> (K, V)) -> [K : V] {
        return Dictionary<K, V>(pairs: self.map{ (k, v) in transform(k, v) })
    }
}
