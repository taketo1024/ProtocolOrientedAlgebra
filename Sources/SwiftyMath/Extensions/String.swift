//
//  String.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/05/08.
//

import Foundation

public extension String {
    
    func substring(_ r: CountableRange<Int>) -> String {
        
        let length = self.count
        let fromIndex = (r.startIndex > 0) ? self.index(self.startIndex, offsetBy: r.startIndex) : self.startIndex
        let toIndex = (length > r.endIndex) ? self.index(self.startIndex, offsetBy: r.endIndex) : self.endIndex
        
        if fromIndex >= self.startIndex && toIndex <= self.endIndex {
            return String( self[fromIndex ..< toIndex] )
        } else {
            return self
        }
    }
    
    func substring(_ r: CountableClosedRange<Int>) -> String {
        
        let from = r.lowerBound
        let to = r.upperBound
        
        return self.substring(from ..< to + 1)
    }
    
    func substring(_ r: CountablePartialRangeFrom<Int>) -> String {
        
        let from = r.lowerBound
        let to = self.count
        
        return self.substring(from ..< to)
    }
    
    func substring(_ r: PartialRangeThrough<Int>) -> String {
        let to = r.upperBound
        
        return self.substring(0 ..< to)
    }
}
