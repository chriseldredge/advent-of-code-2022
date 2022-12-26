import Foundation

public class day25: Puzzle {
    public private(set) var input = [Substring]()
  
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName)
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return ""
    }

    public func part1() -> String {
        let fromSnafu = input.map(parseSnafu)
        let sum = fromSnafu.reduce(0, +)
        return toSnafu(sum)
    }
    
    func parseSnafu(_ s: Substring) -> Int {
        let base = 5
        var mul = 1
        var num = 0
        var digit = 0
        
        for ch in s.reversed() {
            switch ch {
            case "=": digit = -2
            case "-": digit = -1
            default: digit = Int(ch.asciiValue! - UInt8(ascii: "0"))
            }
            
            num += digit * mul
            mul *= base
        }
        
        return num
    }
    
    func toSnafu(_ i: Int) -> String {
        let base = 5
        var b = [Int]()
        var r = i
        var carry = 0
        
        while r > 0 {
            let d = (r+carry) % base
            r = r - d + carry
            r /= base

            if d < 3 {
                b.insert(d, at: b.startIndex)
                carry = 0
            } else {
                carry = 1
                b.insert(d - 5, at: b.startIndex)
            }
            
        }
        
        if carry > 0 {
            b.insert(carry, at: b.startIndex)
        }
        
        return b.map{ i in
            if i == -1 {
                return "-"
            } else if i == -2 {
                return "="
            } else {
                return String(i)
            }
        }.joined()
    }
}
