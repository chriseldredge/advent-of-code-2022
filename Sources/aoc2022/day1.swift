public class day1: Puzzle {
    private var bags = [[Int]]()

    public init() {
    }
    
    public func solve() -> String {
        return """
Top 1: \(self.sumTopBags(n: 1))
Top 3: \(self.sumTopBags(n: 3))
"""
    }
    
    public func sumTopBags(n: Int) -> Int {
        let x = bags
            .map{ $0.reduce(0, +) }
            .sorted{ $0 > $1 }
        
        let s = x[...(n-1)]

        return s.reduce(0, +)
    }

    public func load(resourceName: String) {
        let lines = Resources.loadLines(resoureName: resourceName, omittingEmptySubsequences: false)
        
        bags.removeAll()
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
    }
}

