//
//  Cache.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/08/02.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public final class Cache<T>: CustomStringConvertible {
    public var value: T?
    
    public init(_ value: T? = nil) {
        self.value = value
    }
    
    public static var empty: Cache<T> {
        Cache()
    }
    
    public var hasValue: Bool {
        value != nil
    }
    
    public func useCacheOrSet(_ initializer: () -> T) -> T {
        if let v = value {
            return v
        }
        
        let v = initializer()
        value = v
        return v
    }
    
    public func clear() {
        self.value = nil
    }
    
    public func copy() -> Cache<T> {
        Cache(value)
    }
    
    public var description: String {
        "Cache(\(value.map{ "\($0)" } ?? "-"))"
    }
}

public final class CacheDictionary<K, T>: CustomStringConvertible where K: Hashable {
    private var dictionary: [K : T]
    
    public init(_ dictionary: [K : T] = [:]) {
        self.dictionary = dictionary
    }
    
    public static var empty: CacheDictionary<K, T> {
        CacheDictionary()
    }
    
    public subscript (key: K) -> T? {
        get { dictionary[key] }
        set { dictionary[key] = newValue }
    }
    
    public func useCacheOrSet(key: K, _ initializer: () -> T) -> T {
        if let v = dictionary[key] {
            return v
        }
        
        let v = initializer()
        dictionary[key] = v
        return v
    }
    
    public func remove(key: K) {
        dictionary.removeValue(forKey: key)
    }
    
    public func clear() {
        self.dictionary = [:]
    }
    
    public var description: String {
        "Cache(\(dictionary))"
    }
}
