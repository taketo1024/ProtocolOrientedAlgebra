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
    public func clear() {
        self.value = nil
    }
    public func copy() -> Cache<T> {
        return Cache(value)
    }
    public var description: String {
        return value == nil ? "empty" : "cache(\(value!))"
    }
}
