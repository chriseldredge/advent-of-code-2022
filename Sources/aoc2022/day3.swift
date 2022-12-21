import Foundation

public class day3: Puzzle {
    var input = [Substring]()
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName)
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
    }

    public func part1() -> Int {
        self.divide()
            .map(day3.commonChar)
            .map(day3.priority)
            .reduce(0, +)
    }
    
    public func part2() -> Int {
        stride(from: 0, to: self.input.count, by: 3)
            .map{ Array(self.input[$0 ..< $0 + 3]) }
            .map(day3.commonChar)
            .map(day3.priority)
            .reduce(0, +)
    }
    
    public static func priority(ch: Character) -> Int {
        var a: Character = "a"
        var offset = 1
        if ch.isUppercase {
            a = "A"
            offset = 27
        }
        
        return Int(ch.asciiValue! - a.asciiValue!) + offset
    }
    
    public static func commonChar(_ strs: Substring...) -> Character {
        commonChar(strs)
    }
    
    public static func commonChar(_ strs: [Substring]) -> Character {
        strs
            .map({Set<Character>($0)})
            .reduce(Set<Character>(strs.first!), {$0.intersection($1)})
            .first!
    }
    
    public func divide() -> Array<Array<Substring>> {
        var list = [[Substring]]()
        
        for line in self.input {
            let mid = line.count/2
            let x = [line.prefix(mid), line.suffix(mid)]
            list.append(x)
        }
        return list
    }
}
