//
//  Box.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/14.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public final class Ref<Value> {
    public var value: Value
    public init(_ value: Value) {
        self.value = value
    }
}
