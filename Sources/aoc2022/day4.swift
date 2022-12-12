import Foundation

public class day4: Puzzle {
    var input = [Substring]()
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName)
    }
    
    public func solve() -> String {
        return """
Part 1: \(part1())
Part 2: \(part2())
"""
    }
    
    public func part1() -> Int {
        parse()
            .filter(day4.isRedundant)
            .count
    }
    
    public func part2() -> Int {
        parse()
            .filter{ $0.0.overlaps($0.1) }
            .count
    }
  
    
    public static func isRedundant(r1: ClosedRange<Int>, r2: ClosedRange<Int>) -> Bool {
        isSubrange(enclosing: r1, other: r2) || isSubrange(enclosing: r2, other: r1)
    }
    
    public static func isSubrange(enclosing: ClosedRange<Int>, other: ClosedRange<Int>) -> Bool {
        other.lowerBound >= enclosing.lowerBound && other.lowerBound <= enclosing.upperBound
            && other.upperBound >= enclosing.lowerBound && other.upperBound <= enclosing.upperBound
    }
    
    func parse() -> [(ClosedRange<Int>, ClosedRange<Int>)] {
        self.input
            .map{ $0.components(separatedBy: ",")}
            .map{ ( day4.parseRange($0[0]), day4.parseRange($0[1])) }
    }

    static func parseRange(_ str: String) -> ClosedRange<Int> {
        let bounds = str
            .components(separatedBy: "-")
            .map{ Int($0)! }
        
        return bounds[0]...bounds[1]
    }
}
