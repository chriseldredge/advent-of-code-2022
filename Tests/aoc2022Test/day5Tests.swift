import aoc2022
import XCTest

final class day5Tests : XCTestCase {
    public func testParse() {
        let subject = day5()
        subject.load(resourceName: "day5-sample")
      
        XCTAssertEqual(Set(subject.stacks.keys), ["1", "2", "3"])
        XCTAssertEqual(subject.stacks["1"]!.contents, ["Z", "N"])
        XCTAssertEqual(subject.stacks["2"]!.contents, ["M", "C", "D"])
    }
    
    public func testPart1SampleAnswer() {
        let subject = day5()
        subject.load(resourceName: "day5-sample")
        
        let actual = subject.part1()
        
        XCTAssertEqual(actual, "CMZ")
    }
        
    public func testPart2SampleAnswer() {
        let subject = day5()
        subject.load(resourceName: "day5-sample")
        
        let actual = subject.part2()
        
        XCTAssertEqual(actual, "MCD")
    }

    public func testPop2() {
        var s = day5.CharStack()
        s.push("A")
        s.push("B")
        
        let actual = s.pop(2)
        
        XCTAssertEqual(actual, ["A", "B"])
    }
}

