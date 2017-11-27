//
//  Dictionary.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

internal extension Dictionary {
    internal init<S: Sequence>(pairs: S) where S.Element == (Key, Value) {
        self.init(uniqueKeysWithValues: pairs)
    }

    internal init<S: Sequence>(keys: S, generator: (Key) -> Value) where S.Element == Key {
        self.init(pairs: keys.map{ ($0, generator($0))} )
    }
}
