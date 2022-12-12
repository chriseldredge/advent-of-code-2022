import ArgumentParser

@main
struct Repeat: ParsableCommand {
    @Option(name: .shortAndLong, help: "Puzzle number to run")
    var puzzle: Int? = nil
    
    @Option(name: .shortAndLong, help: "Puzzle input")
    var input: String? = nil

    mutating func run() throws {
        if let num = puzzle {
            Puzzles().solve(day: num, resourceName: input)
        } else {
            Puzzles().solveAll()
        }
    }
}


