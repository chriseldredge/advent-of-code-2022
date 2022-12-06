import Foundation

public class day5: Puzzle {
    public private(set) var stacks: [String: CharStack]
    public private(set) var moves: [Move]
    
    public init(input: Array<Substring>) {
        self.stacks = day5.parseStacks(input: input)
        self.moves = day5.parseMoves(input: input)
    }
    
    public convenience init() {
        self.init(input: day5.load())
    }
    
    public func solve() -> String {
        return """
Part 1: \(day5().part1())
Part 2: \(day5().part2())
"""
    }
    
    public func part1() -> String {
        for m in moves {
            for _ in 1...m.qty {
                let c = self.stacks[m.from]!.pop()
                self.stacks[m.to]?.push(c)
            }
        }
        
        return stacks.keys
            .sorted()
            .map{ String(stacks[$0]!.peek()) }
            .reduce("", +)
    }
    
    public func part2() -> String {
        for m in moves {
            let top = self.stacks[m.from]!.pop(m.qty)
            for ch in top {
                self.stacks[m.to]?.push(ch)
            }
        }
        
        return stacks.keys
            .sorted()
            .map{ String(stacks[$0]!.peek()) }
            .reduce("", +)
    }

    public static func parseStacks(input: [Substring]) -> [String: CharStack] {
        let div = input.firstIndex(where: \.isEmpty)! - 1
        let stackNames = input[div]
        var stacks = [String: CharStack]()
        
        for (column, key) in stackNames.enumerated() {
            if key == " " {
                continue
            }
            var stack = CharStack()
            
            let state = input[input.startIndex..<div]
                .map{ (line) in line[line.index(line.startIndex, offsetBy: column)]}
                .filter( \.isLetter )
                .reversed()
            
            for ch in state {
                stack.push(ch)
            }
            
            stacks[String(key)] = stack
        }

        return stacks
    }
    
    public static func parseMoves(input: [Substring]) -> [Move] {
        let div = input.firstIndex(where: \.isEmpty)! + 1
            
        return input[div..<input.endIndex]
            .filter{ $0.starts(with: "move") }
            .map{ (line) in
                let args = line.components(separatedBy: " ")
                return Move(qty: Int(args[1])!, from: args[3], to: args[5])
            }
    }
    
    public static func load(resourceName: String = "day5") -> Array<Substring> {
        Resources.loadLines(resoureName: resourceName, omittingEmptySubsequences: false)
    }
    
    public typealias Move = (qty: Int, from: String, to: String)
    public typealias CharStack = Stack<Character>
    
    public struct Stack<T> {
        var arr = [T]()
        
        public init() {
        }
        
        public mutating func push(_ ch: T) {
            arr.append(ch)
        }
        
        public mutating func pop() -> T {
            arr.removeLast()        }
        
        public mutating func pop(_ n: Int) -> [T] {
            let range = arr.endIndex - n ..< arr.endIndex
            let top = Array(arr[range])
            arr.removeSubrange(range)
            return top
        }
        
        public func peek() -> T {
            arr.last!
        }
        
        public var contents: [T] {
            arr
        }
    }
    
}
