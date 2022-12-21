import ArgumentParser

public protocol AdventOptions {
    var part: Int? { get }
}

@main
struct Advent: ParsableCommand, AdventOptions {
    @Option(name: .shortAndLong, help: "Puzzle number to run")
    var day: Int

    @Option(name: .shortAndLong, help: "Puzzle part to run")
    var part: Int? = nil

    @Option(name: .shortAndLong, help: "Puzzle input")
    var input: String? = nil

    mutating func run() throws {
        Puzzles().solve(day: day, resourceName: input, options: self)
    }
}


