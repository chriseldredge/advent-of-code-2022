import Foundation

public class day6: Puzzle {
    public private(set) var input: Substring
    
    public init(input: Substring) {
        self.input = input
    }
    
    public convenience init() {
        self.init(input: day6.load())
    }
    
    public func solve() -> String {
        return """
Part 1: \(day6().part1())
Part 2: \(day6().part2())
"""
    }
    
    public func part1() -> Int {
        day6.startOfPacket(self.input)
    }
    
    public func part2() -> Int {
        day6.startOfMessage(self.input)
    }
    
    public static func startOfPacket(_ input: Substring) -> Int {
        offsetAfterDistinct(input, count: 4)
    }
    
    public static func startOfMessage(_ input: Substring) -> Int {
        offsetAfterDistinct(input, count: 14)
    }
    
    public static func offsetAfterDistinct(_ input: Substring, count: Int) -> Int {
        var offset = 0
        var index = input.startIndex
        var r = index..<input.index(index, offsetBy: count)
        
        while Set(input[r]).count != count {
            offset += 1
            index = input.index(input.startIndex, offsetBy: offset)
            r = index..<input.index(index, offsetBy: count)
        }
        
        return offset+count
    }

    public static func load(resourceName: String = "day6") -> Substring {
        Resources.loadLines(resoureName: resourceName).first!
    }
}
