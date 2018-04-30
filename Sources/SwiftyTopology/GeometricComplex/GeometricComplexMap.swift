//
//  GeometricComplexMap.swift
//  SwiftyTopology
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public protocol GeometricComplexMap: MapType where Complex.Map == Self, Domain == Complex.Cell, Codomain == Complex.Cell {
    associatedtype Complex: GeometricComplex
    
    static func inclusion(from: Complex, to: Complex) -> Self
    static func diagonal(from: Complex) -> Self
}
