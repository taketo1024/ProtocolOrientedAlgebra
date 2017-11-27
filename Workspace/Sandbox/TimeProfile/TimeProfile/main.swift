//
//  main.swift
//  TimeProfile
//
//  Created by Taketo Sano on 2017/10/23.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

func main() {
    typealias Z = IntegerNumber

    let T = SimplicialComplex.torus(dim: 4)
    let H = Homology(T, Z.self)
    print("H(T; Z) =", H.detailDescription, "\n")
}

main()
