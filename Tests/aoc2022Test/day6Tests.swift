import aoc2022
import XCTest

final class day6Tests : XCTestCase {
    public func testStartOfPacket() {
        XCTAssertEqual(day6.startOfPacket("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 7)
        XCTAssertEqual(day6.startOfPacket("bvwbjplbgvbhsrlpgdmjqwftvncz"), 5)
        XCTAssertEqual(day6.startOfPacket("nppdvjthqldpwncqszvftbrmjlhg"), 6)
        XCTAssertEqual(day6.startOfPacket("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 10)
        XCTAssertEqual(day6.startOfPacket("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 11)
    }
    
    public func testStartOfMessage() {
        XCTAssertEqual(day6.startOfMessage("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 19)
        XCTAssertEqual(day6.startOfMessage("bvwbjplbgvbhsrlpgdmjqwftvncz"), 23)
        XCTAssertEqual(day6.startOfMessage("nppdvjthqldpwncqszvftbrmjlhg"), 23)
        XCTAssertEqual(day6.startOfMessage("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 29)
        XCTAssertEqual(day6.startOfMessage("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 26)
    }
}

