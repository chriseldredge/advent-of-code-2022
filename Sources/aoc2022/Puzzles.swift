public protocol Puzzle {
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
        day7()
    ] as [Puzzle]

    public func solveAll() {
        for i in items {
            print("==================== \(i) ====================")
            print(i.solve())
        }
    }
}
