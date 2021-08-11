//
//  Cache.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/08/02.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Dispatch

public final class Cache<Key, Value>: ExpressibleByDictionaryLiteral, CustomStringConvertible where Key: Hashable {
    private var storage: [Key : Value]
    private let queue = DispatchQueue(label: "Cache", qos: .userInteractive)

    public init(_ storage: [Key : Value] = [:]) {
        self.storage = storage
    }
    
    public convenience init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(elements))
    }
    
    public static var empty: Cache<Key, Value> {
        [:]
    }
    
    public subscript (key: Key) -> Value? {
        get {
            queue.sync { storage[key] }
        }
        set {
            queue.sync { storage[key] = newValue }
        }
    }
    
    public func getOrSet(key: Key, _ initializer: () -> Value) -> Value {
        if let value = self[key] {
            return value
        }
        
        let value = initializer()
        
        self[key] = value
        return value
    }

    public func remove(key: Key) {
        queue.sync {
            let _ = storage.removeValue(forKey: key)
        }
    }
    
    public func clear() {
        queue.sync {
            self.storage = [:]
        }
    }
    
    public var description: String {
        queue.sync {
            "Cache\(storage)"
        }
    }
}
