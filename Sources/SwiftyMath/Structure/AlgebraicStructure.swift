//
//  DynamicType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/04.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

// A `Structure` instance expresses a mathematical structure that is determined dynamically.
// Used when we want a 'dynamic-type', where Swift-types are strictly static.
//
// * All finite subgroups of a finite (static) group.
// * The invariant factor decomposition of a given f.g. module.
// * The Homology group of a given SimplicialComplex.

public protocol AlgebraicStructure: class, Equatable, CustomStringConvertible { }

