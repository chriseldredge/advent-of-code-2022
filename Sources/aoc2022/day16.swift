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
                
        let a = g.next()
        print("Recursions=\(g.numRecursions)")
        return a
    }
    
    public func part2() -> Int {
        0
    }
    
    static func parse(input: [Substring]) -> Graph {
        var vertMap = [String: Int]()
        
        let wordLines = input.map{ $0.components(separatedBy: .whitespaces) }
        let keys = wordLines.map { $0[1] }
        
        for (index, key) in keys.enumerated() {
            vertMap[key] = index
        }
        
        let g = Graph()
        
        for words in wordLines {
            let rate = Int(words[4].components(separatedBy: "=").last!.trimmingCharacters(in: .punctuationCharacters))!
            let adj = words[9...]
                .map{ vertMap[$0.trimmingCharacters(in: .punctuationCharacters)]! }
            g.addVertex(name: words[1], rate: rate, adj: adj)
        }
        
        return g
    }
    
    class Graph: CustomStringConvertible {
        var adj = [[Int]]()
        var rates = [Int]()
        var names = [String]()
        var numRecursions = 0
        
        var v: Int {
            adj.count
        }
        
        func addVertex(name: String, rate: Int, adj: [Int]) {
            self.names.append(name)
            self.adj.append(adj)
            self.rates.append(rate)
        }
        
        var description: String {
            "Graph rates=\(rates) adj=\(adj)"
        }
    
        func next() -> Int {
            let candidates = rates.enumerated()
                .filter{ $0.1 > 0 }
                .map { $0.0 }
            
            let start = names.firstIndex(of: "AA")!
            let mins = 30
            
            return brute(location: start, candidates: Set(candidates), mins: mins, sum: 0)
        }
        
        func brute(location: Int, candidates: Set<Int>, mins: Int, sum: Int) -> Int {
            guard mins > 0 else {
                return sum
            }
            numRecursions += 1
            var best = sum
            var prio = [(u: Int, c: Set<Int>, bp: Int, score: Int, cost: Int)]()
            for u in candidates {
                var pred = [Int]()
                var dist = [Int]()

                bfs(start: location, end: u, pred: &pred, dist: &dist)
                
                let cost = dist[u] + 1
                if cost >= mins {
                    continue
                }
                let score = rates[u] * max(0, mins - cost)
                
                var remCan = Set(candidates)
                remCan.remove(u)
                
                let bp = sum + score + bestPossible(candidates: remCan, mins: mins - cost)
                prio.append((u: u, c: remCan, bp: bp, score: score, cost: cost))
            }

            for u in prio.sorted(by: { $0.bp > $1.bp }) {
                if best > u.bp {
                    continue
                }
                best = max(best, brute(location: u.u, candidates: u.c, mins: mins - u.cost, sum: sum + u.score))
            }
            return best
        }
        
        func bestPossible(candidates: Set<Int>, mins: Int) -> Int {
            var sum = 0
            for (index, rate) in candidates.map( { rates[$0] }).sorted(by: { $0 > $1 }).enumerated() {
                sum += rate * max(0, mins - (index+1)*2)
            }
            return sum
        }
        
        func bfs(start: Int, end: Int, pred: inout [Int], dist: inout [Int]) {
            var queue = [start]
            var visited = [Bool](repeating: false, count: v)

            pred = [Int](repeating: -1, count: v)
            dist = [Int](repeating: Int.max, count: v)

            visited[start] = true
            dist[start] = 0
            
            while !queue.isEmpty {
                let u = queue.removeFirst()
                
                for neigh in adj[u] {
                    if visited[neigh] {
                        continue
                    }
                    visited[neigh] = true
                    dist[neigh] = dist[u] + 1
                    pred[neigh] = u
                    queue.append(neigh)
                    
                    if neigh == end {
                        return
                    }
                }
            }
            
            fatalError("No path from \(start) to \(end)")
        }
    }
}
