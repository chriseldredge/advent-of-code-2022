public protocol Puzzle {
    func load(resourceName: String)
    func solve() -> String
}

public class Puzzles {
    let items = [
        day1(),
        day2(),
        day3(),
        day4(),
        day5(),
        day6(),
        day7(),
        day8(),
        day9(),
        day10(),
        day11(),
        day12(),
        day13(),
        day14(),
        day15(),
        day16(),
        day17(),
    ] as [Puzzle]

    public func solveAll() {
        for (i, p) in [day17()].enumerated() {
            print("==================== Day \(i+1) ====================")
            p.load(resourceName: "day\(i+1)")
            print(p.solve())
        }
    }
    
    public func solve(day: Int, resourceName: String?) {
        let p = items[day-1]
        p.load(resourceName: resourceName ?? "day\(day)")
        print(p.solve())
    }
}
