import aoc2022
import XCTest

final class day2Tests : XCTestCase {
    public func testDefeatsShape() {
        XCTAssertEqual(day2.Shape.rock.defeatsShape, day2.Shape.scissors)
        XCTAssertEqual(day2.Shape.paper.defeatsShape, day2.Shape.rock)
        XCTAssertEqual(day2.Shape.scissors.defeatsShape, day2.Shape.paper)
    }
}

