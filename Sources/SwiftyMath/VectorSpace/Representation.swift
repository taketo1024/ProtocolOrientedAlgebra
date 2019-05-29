//
//  Representation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/23.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol Representation: MapType where Codomain: LinearEndType, Codomain.Domain == BaseVectorSpace {
    associatedtype BaseVectorSpace
    subscript(_ x: Domain) -> Codomain { get }
}

extension Representation {
    public subscript(_ x: Domain) -> Codomain {
        return applied(to: x)
    }
}
