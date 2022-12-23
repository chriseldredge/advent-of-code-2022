import aoc2022
import XCTest

final class day22Tests : XCTestCase {
    func testAround() {
        let subject = day22()

        subject.load(resourceName: "day22")
        subject.input = subject.input.map{ Substring($0.replacingOccurrences(of: "#", with: ".")) }
        let (map, _) = subject.parse()
        let solver = day22.CubeSolver(map: map)
        var position = map.startingPoint
        
        for _ in 0..<200 {
            position = solver.nextPosition(position)
        }
        
        XCTAssertEqual(position, map.startingPoint)
        
        solver.facingIndex = 1
        position = map.startingPoint

        for _ in 0..<200 {
            position = solver.nextPosition(position)
        }

        XCTAssertEqual(position, map.startingPoint)
    
        solver.facingIndex = 2
        position = map.startingPoint

        for _ in 0..<200 {
            position = solver.nextPosition(position)
        }
        
        XCTAssertEqual(position, map.startingPoint)

        solver.facingIndex = 3
        let s = day22.Point(x: 5, y: 117)
        
        position = s

        for _ in 0..<200 {
            position = solver.nextPosition(position)
        }
        
        XCTAssertEqual(position, s)
        
        solver.facingIndex = 1
        
        position = s

        for _ in 0..<200 {
            position = solver.nextPosition(position)
        }
        
        XCTAssertEqual(position, s)
    }
}

