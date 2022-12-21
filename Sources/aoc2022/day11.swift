import Foundation

public class day11: Puzzle {
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
        return "\(part2())"
    }

    public func part1() -> Int {
        let d = day11.parse(self.input)
        for _ in 1...20 {
            day11.cycle(d, tfm: { $0 / 3 })
        }
        
        let top = d.sorted(by: { $0.hitCount > $1.hitCount })
        
        return top[0].hitCount * top[1].hitCount
    }
    
    public func part2() -> Int {
        let d = day11.parse(self.input)
        for _ in 1...10000 {
            day11.cycle(d)
        }
        
        let top = d.sorted(by: { $0.hitCount > $1.hitCount })
        
        return top[0].hitCount * top[1].hitCount
    }
    
    public static func cycle(_ d: [Monkey], tfm: (Int) -> Int = {$0}) {
        let lcm = d.map{ $0.testDivBy }.reduce(1, *)
        
        for m in d {
            for item in m.inspectItems() {
                let arg = Int(m.arg) ?? item
                let worry = tfm((m.op == "+" ? (item + arg) : (item * arg))) % lcm
                
                let test = worry % m.testDivBy == 0
                let target = m.targets[test]!
                d[target].anticipate(worry)
            }
        }
    }
    
    public static func parse(_ input: [Substring]) -> [Monkey] {
        var dict = [Monkey]()

        for idx in stride(from: input.startIndex, to: input.endIndex, by: 6) {
            let items = input[idx+1]
                .components(separatedBy: ":")
                .last!
                .components(separatedBy: ",")
                .map{ Int($0.trimmingCharacters(in: .whitespaces))! }
            let op = input[idx+2].charAt(23)
            let arg = input[idx+2].components(separatedBy: .whitespaces).last!
            let testDivBy = Int(input[idx+3].components(separatedBy: .whitespaces).last!)!
            
            var targets = [Bool: Int]()

            targets[true] = Int(input[idx+4].components(separatedBy: .whitespaces).last!)!
            targets[false] = Int(input[idx+5].components(separatedBy: .whitespaces).last!)!
            
            dict.append(Monkey(items: items, op: op, arg: arg, testDivBy: testDivBy, targets: targets))
        }
        return dict
    }
    
    public class Monkey {
        var items = [Int]()
        var hitCount: Int = 0
        let op: Character
        let arg: String
        let testDivBy: Int
        let targets: [Bool: Int]
        
        init(items: [Int] = [Int](), op: Character, arg: String, testDivBy: Int, targets: [Bool: Int]) {
            self.items = items
            self.op = op
            self.arg = arg
            self.testDivBy = testDivBy
            self.targets = targets
        }
        
        public func inspectItems() -> [Int] {
            hitCount += Int(items.count)
            
            let tmp = Array(items)
            items = [Int]()
            return tmp
        }
        
        public func anticipate(_ item: Int) {
            items.append(item)
        }
    }
}

extension Substring {
    func charAt(_ index: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: index)]
    }
}

