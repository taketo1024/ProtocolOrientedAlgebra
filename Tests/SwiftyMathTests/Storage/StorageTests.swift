//
//  StorageTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2018/04/23.
//

import XCTest
@testable import SwiftyMath

class StorageTests: XCTestCase {

    struct A: Codable, Equatable {
        let a: Int
    }

    override func setUp() {
        super.setUp()
        Storage.setTestMode(true)
        Storage.clear()
    }

    override func tearDown() {
        Storage.clear()
        Storage.setTestMode(false)
        super.tearDown()
    }

    func testExists() {
        XCTAssertFalse(Storage.exists("none"))
    }

    func testSaveLoad() {
        let a = A(a: 10)
        let id = "a"

        XCTAssertFalse(Storage.exists(id))

        Storage.save(id, a)
        XCTAssertTrue(Storage.exists(id))

        if let b = Storage.load(id, A.self) {
            XCTAssertEqual(a, b)
        } else {
            XCTFail()
        }
    }

    func testSaveDelete() {
        let a = A(a: 10)
        let id = "a"

        XCTAssertFalse(Storage.exists(id))

        Storage.save(id, a)
        XCTAssertTrue(Storage.exists(id))

        Storage.delete(id)
        XCTAssertFalse(Storage.exists(id))
    }

    func testUseCache() {
        var x = 0
        let id = "a"

        let f = { () -> A in
            return Storage.useCache(id) {
                x += 1
                return A(a: 10)
            }
        }

        XCTAssertFalse(Storage.exists(id))

        let a = f()

        XCTAssertTrue(Storage.exists(id))
        XCTAssertEqual(a, A(a: 10))
        XCTAssertEqual(x, 1)

        let b = f()

        XCTAssertTrue(Storage.exists(id))
        XCTAssertEqual(b, A(a: 10))
        XCTAssertEqual(x, 1) // cache used
    }
}
