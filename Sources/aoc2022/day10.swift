import Foundation

public class day10: Puzzle {
    public private(set) var input: [Substring]
    
    public init(input: [Substring]) {
        self.input = input
    }
    
    public convenience init() {
        self.init(input: day10.load())
    }
    
    public func solve() -> String {
        return """
Part 1: \(day10().part1())
Part 2:\n\(day10().part2())
"""
    }
    
    public func part1() -> Int {
        let p = puter()
        p.run(input)
        return p.sigs.reduce(0, +)
    }
    
    public func part2() -> String {
        let p = puter()
        p.run(input)
        
        return p.crt.map{ String($0) }.joined(separator: "\n")
    }

    class puter {
        var ticks = 0
        var x = 1
        var sigs = [Int]()
        var crt = [[Character]]()
        
        init() {
            for _ in 1...6 {
                crt.append(Array<Character>(repeating: ".", count: 40))
            }
        }

        func run(_ input: [Substring]) {
            for line in input {
                let parts = line.components(separatedBy: .whitespaces)
                let op = parts[0]
                var arg = ""
                if parts.count > 1 {
                    arg = parts[1]
                }
                
                execute(op: op, arg: arg)
            }
        }
        
        func execute(op: String, arg: String = "") {
            switch op {
            case "noop":
                tick()
                break
            case "addx":
                tick()
                tick()
                x += Int(arg)!
                break
            default:
                break
            }
        }
        
        func tick() {
            let bx = ticks % 40
            let by = (ticks / 40) % 6
            
            if x == bx || x-1 == bx || x+1 == bx {
                crt[by][bx] = "#"
            }

            self.ticks += 1
            
            if self.ticks == 20 || (self.ticks - 20) % 40 == 0 {
                sigs.append(self.ticks * x)
            }
        }
    }
    
    public static func load(resourceName: String = "day10") -> [Substring] {
        Resources.loadLines(resoureName: resourceName)
    }
}

