import Foundation

public class day6: Puzzle {
    public private(set) var input: Substring = ""
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName).first!
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
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
}
