//
//  Cache.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/08/02.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Dispatch

public final class Cache<Key, Value>: ExpressibleByDictionaryLiteral, CustomStringConvertible where Key: Hashable {
    
    // access to storage and locks must be synchronized globally.
    private let global = DispatchQueue(label: "Cache", qos: .userInteractive)
    private var keyLocks: [Key : DispatchSemaphore] = [:]
    private var storage: [Key : Value]

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
            local(key).sync {
                get(key)
            }
        } set {
            local(key).sync {
                set(key, newValue)
            }
        }
    }
    
    public func getOrSet(key: Key, _ initializer: () -> Value) -> Value {
        local(key).sync {
            if let value = get(key) {
                return value
            }
            
            let value = initializer() // this might be time consuming.
            
            set(key, value)
            
            return value
        }
    }

    public func remove(key: Key) {
        global.sync {
            let _ = storage.removeValue(forKey: key)
            let _ = keyLocks.removeValue(forKey: key)
        }
    }
    
    public func clear() {
        global.sync {
            self.storage = [:]
            self.keyLocks = [:]
        }
    }
    
    public var description: String {
        "Cache\(storage)"
    }
    
    private func local(_ key: Key) -> DispatchSemaphore {
        global.sync { () -> DispatchSemaphore in
            if let lock = keyLocks[key] {
                return lock
            } else {
                let lock = DispatchSemaphore(value: 1)
                keyLocks[key] = lock
                return lock
            }
        }
    }
    
    private func get(_ key: Key) -> Value? {
        global.sync { storage[key] }
    }
    
    private func set(_ key: Key, _ value: Value?) {
        global.sync { storage[key] = value }
    }
}

private extension DispatchSemaphore {
    func sync<Result>(_ block: () -> Result) -> Result {
        wait()
        defer { signal() }
        return block()
    }
}
