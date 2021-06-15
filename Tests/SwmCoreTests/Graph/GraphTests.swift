//
//  File.swift
//  
//
//  Created by Taketo Sano on 2021/06/04.
//

import XCTest
@testable import SwmCore

class GraphTests: XCTestCase {
    func testTopologicalSort() {
        let G = PlainGraph(structure: [
            0: [2, 3],
            1: [2],
            2: [],
            3: [1, 2],
            4: [1]
        ])
        guard let sorted = try? G.topologicalSort().map({ $0.id }) else {
            XCTFail()
            return
        }
        
        let order = (0 ... 4).map { i in sorted.firstIndex(of: i)! }
        print(sorted)
        XCTAssertTrue(order[0] < order[2])
        XCTAssertTrue(order[0] < order[3])
        XCTAssertTrue(order[1] < order[2])
        XCTAssertTrue(order[3] < order[1])
        XCTAssertTrue(order[3] < order[2])
        XCTAssertTrue(order[4] < order[1])
    }
}
