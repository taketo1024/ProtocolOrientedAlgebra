//
//  ModuleStructure.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/12.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public class ModuleStructure<R: Ring>: AlgebraicStructure {
    public static func ==(lhs: ModuleStructure<R>, rhs: ModuleStructure<R>) -> Bool {
        fatalError("implement in subclass")
    }

    public var description: String {
        return "\(type(of: self))"
    }
}

