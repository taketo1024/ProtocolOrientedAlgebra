//
//  String.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/05/08.
//

public extension String {
    subscript(_ r: CountableRange<Int>) -> Substring {
        let from = index(startIndex, offsetBy: r.lowerBound)
        let to   = index(startIndex, offsetBy: r.upperBound)
        return self[from ..< to]
    }
    
    subscript(_ r: CountableClosedRange<Int>) -> Substring {
        let from = index(startIndex, offsetBy: r.lowerBound)
        let to   = index(startIndex, offsetBy: r.upperBound)
        return self[from ... to]
    }
    
    subscript(_ r: CountablePartialRangeFrom<Int>) -> Substring {
        self[r.lowerBound ..< self.count]
    }
    
    subscript(_ r: PartialRangeThrough<Int>) -> Substring {
        self[0 ..< r.upperBound]
    }
}
