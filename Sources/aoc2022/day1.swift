public class day1: Puzzle {
    private static let data = parse()

    public func solve() -> String {
        return """
Top 1: \(self.sumTopBags(n: 1))
Top 3: \(self.sumTopBags(n: 3))
"""
    }
    
    public func sumTopBags(n: Int) -> Int {
        let x = day1.data
            .map{ $0.reduce(0, +) }
            .sorted{ $0 > $1 }
        
        let s = x[...(n-1)]

        return s.reduce(0, +)
    }

    static func parse() -> Array<Array<Int>> {
        let lines = Resources.loadLines(resoureName: "day1")
        var bags = [[Int]]()
        var bag = [Int]()
        
        for line in lines {
            if (line.isEmpty && !bag.isEmpty) {
                bags.append(bag)
                bag = [Int]()
            } else {
                bag.append(Int(line) ?? 0)
            }
        }

        if (!bag.isEmpty) {
            bags.append(bag)
        }
        
        return bags
    }
}

