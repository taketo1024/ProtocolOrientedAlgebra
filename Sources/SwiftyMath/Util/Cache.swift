//
//  Cache.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/08/02.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Dispatch

public final class Cache<T>: CustomStringConvertible {
    private var _value: T?
    private let queue: DispatchQueue
    
    public init(_ value: T? = nil) {
        self._value = value
        self.queue = DispatchQueue(label: "Cache", qos: .userInteractive)
    }
    
    public static var empty: Cache<T> {
        Cache()
    }
    
    public var value: T? {
        get {
            queue.sync{ _value }
        }
        set {
            queue.sync{ _value = newValue }
        }
    }
    
    public var hasValue: Bool {
        value != nil
    }
    
    public func useCacheOrSet(_ initializer: () -> T) -> T {
        queue.sync {
            if let v = _value {
                return v
            }
            
            let v = initializer()
            _value = v
            return v
        }
    }
    
    public func clear() {
        queue.sync {
            _value = nil
        }
    }
    
    public func copy() -> Cache<T> {
        queue.sync {
            Cache(_value)
        }
    }
    
    public var description: String {
        queue.sync {
            "Cache(\(value.map{ "\($0)" } ?? "-"))"
        }
    }
}

public final class CacheDictionary<K, T>: CustomStringConvertible where K: Hashable {
    private var dictionary: [K : T]
    private let queue: DispatchQueue

    public init(_ dictionary: [K : T] = [:]) {
        self.dictionary = dictionary
        self.queue = DispatchQueue(label: "CacheDictionary", qos: .userInteractive)
    }
    
    public static var empty: CacheDictionary<K, T> {
        CacheDictionary()
    }
    
    public subscript (key: K) -> T? {
        get {
            queue.sync { dictionary[key] }
        }
        set {
            queue.sync { dictionary[key] = newValue }
        }
    }
    
    public func useCacheOrSet(key: K, _ initializer: () -> T) -> T {
        queue.sync {
            if let v = dictionary[key] {
                return v
            }
            
            let v = initializer()
            dictionary[key] = v
            return v
        }
    }
    
    public func remove(key: K) {
        queue.sync {
            let _ = dictionary.removeValue(forKey: key)
        }
    }
    
    public func clear() {
        queue.sync {
            self.dictionary = [:]
        }
    }
    
    public var description: String {
        queue.sync {
            "Cache(\(dictionary))"
        }
    }
}
