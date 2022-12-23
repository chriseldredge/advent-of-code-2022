public protocol Puzzle {
    func load(resourceName: String)
    func solvePart1() -> String
    func solvePart2() -> String
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
        day18(),
        day19(),
        day20(),
        day21(),
        day22(),
    ] as [Puzzle]
    
    public func solve(day: Int, resourceName: String?, options: AdventOptions) {
        let p = items[day-1]
        p.load(resourceName: resourceName ?? "day\(day)")
        print("==================== Day \(day) ====================")
        
        if let part = options.part {
            if part == 1 {
                print(p.solvePart1())
            } else if part == 2 {
                print(p.solvePart2())
            }
        } else {
            print("Part 1: " + p.solvePart1())
            print("Part 2: " + p.solvePart2())
        }
    }
}
