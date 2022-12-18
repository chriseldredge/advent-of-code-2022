import Foundation

public class day16: Puzzle {
    public private(set) var input = [Substring]()

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
        let g = day16.parse(input: input)
        
        g.calcDist()
        print("dist=\(g.dists)")
        let ans = g.maxp("AA", 0, 0, 30, Set<String>(["AA"]))
        print("Recursions=\(g.numRecursions)")

        return ans
    }
    
    public func part2() -> Int {
        0
    }
    
    static func parse(input: [Substring]) -> Graph {
        let wordLines = input.map{ $0.components(separatedBy: .whitespaces) }
        
        let g = Graph()
        
        for words in wordLines {
            let rate = Int(words[4].components(separatedBy: "=").last!.trimmingCharacters(in: .punctuationCharacters))!
            let v = words[1]
            let adj = words[9...]
                .map{ $0.trimmingCharacters(in: .punctuationCharacters) }
            g.addVertex(name: v, rate: rate, adj: adj)
        }
        
        return g
    }
    
    class Graph {
        var adj = [String: [String]]()
        var rates = [String: Int]()
        var numRecursions = 0
        var dists = [String: [String: Int]]()
        
        var v: Int {
            adj.count
        }
        
        func addVertex(name: String, rate: Int, adj: [String]) {
            self.adj[name] = adj
            
            if rate > 0 || name == "AA" {
                self.rates[name] = rate
            }
        }
        
        func calcDist() {
            let targets = Set(rates.keys)
            
            for v in targets {
                calcDist(v, targets)
            }
        }
        
        func calcDist(_ s: String, _ targets: Set<String>) {
            var dist = [String: Int]()
            var q = [(String, Int)]()
            var visited = Set<String>([s])
            
            for n in adj[s]! {
                q.append((n, 1))
            }
            
            while dist.count < targets.count - 1 {
                let (v, d) = q.removeFirst()

                if visited.contains(v) {
                    continue
                }
                visited.insert(v)
                
                if targets.contains(v) {
                    dist[v] = d
                }
                
                for n in adj[v]! {
                    q.append((n, d+1))
                }
            }
            
            dists[s] = dist
        }
        
        func maxp(_ v: String, _ p: Int, _ m: Int, _ tm: Int, _ visited: Set<String>) -> Int {
            numRecursions += 1
            
            var best = p * (tm - m)
            
            for (n, dist) in dists[v]! {
                if visited.contains(n) {
                    continue
                }
                
                let cost = dist + 1
                if m + cost >= tm {
                    continue
                }
                
                best = max(best, p * cost + maxp(n, p + rates[n]!, m+cost, tm, visited.union([v])))
            }
            
            return best
        }
    }
}
