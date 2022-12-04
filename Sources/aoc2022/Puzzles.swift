public protocol Puzzle {
    func solve() -> String
}

public class Puzzles {
    let items = [
        day1(),
        day2(),
        day3()
    ] as [Puzzle]

    public func solveAll() {
        for i in items {
            print("==================== \(i) ====================")
            print(i.solve())
        }
    }
}
