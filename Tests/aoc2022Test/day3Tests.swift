import aoc2022
import XCTest

final class day3Tests : XCTestCase {
    public func testParse() {
        let subject = day3()
        subject.load(resourceName: "day3-sample")
        
        let data = subject.divide()
        
        XCTAssertGreaterThan(data.count, 0)
        for arr in data {
            XCTAssertEqual(arr.first!.count, arr.last!.count)
        }
    }
    
    public func testCommonChar2() {
        let result = day3.commonChar("abc", "AbC")
        
        XCTAssertEqual(result, "b")
    }
        
    public func testCommonChar() {
        let result = day3.commonChar("abc", "abC", "aBC")
        
        XCTAssertEqual(result, "a")
    }
    
    public func testPart1SampleAnswer() {
        let subject = day3()
        subject.load(resourceName: "day3-sample")
        
        let actual = subject.part1()
        
        XCTAssertEqual(actual, 157)
    }
        
    public func testPart2SampleAnswer() {
        let subject = day3()
        subject.load(resourceName: "day3-sample")
        
        let actual = subject.part2()
        
        XCTAssertEqual(actual, 70)
    }

}

