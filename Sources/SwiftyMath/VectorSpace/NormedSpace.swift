//
//  NormedSpace.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/20.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

// MEMO: not made as a subprotocol of VectorSpace
public protocol NormedSpace {
    var norm: 𝐑 { get }
}

extension AsVectorSpace: NormedSpace where R: NormedSpace {
    public var norm: 𝐑 {
        return value.norm
    }
}
