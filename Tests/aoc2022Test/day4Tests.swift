import aoc2022
import XCTest

final class day4Tests : XCTestCase {
    public func testIsSubrange() {
        XCTAssertTrue(day4.isSubrange(enclosing: 0...2, other: 1...1))
        XCTAssertFalse(day4.isSubrange(enclosing: 0...2, other: 1...3))
        XCTAssertFalse(day4.isSubrange(enclosing: 3...5, other: 1...10))
    }
    
    public func testIsRedundant() {
        XCTAssertTrue(day4.isRedundant(r1: 3...5, r2: 1...10))
    }
    
    public func testPart1SampleAnswer() {
        let subject = day4(input: day4.load(resourceName: "day4-sample"))
        
        let actual = subject.part1()
        
        XCTAssertEqual(actual, 2)
    }
        
    public func testPart2SampleAnswer() {
        let subject = day4(input: day4.load(resourceName: "day4-sample"))
        
        let actual = subject.part2()
        
        XCTAssertEqual(actual, 4)
    }

}

