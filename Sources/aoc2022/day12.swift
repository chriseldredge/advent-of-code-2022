import Foundation

public class day12: Puzzle {
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
        let g = Graph(input)
        var pred = [Int]()
        var dist = [Int]()

        if !g.bfs(starts: [g.start], pred: &pred, dist: &dist) {
            return -1
        }
        
        return dist[g.end]
    }
    
    public func part2() -> Int {
        let g = Graph(input)
        var starts = [Int]()
        for (i, ch) in g.topos.enumerated() {
            if ch == UInt8(ascii:"a") {
                starts.append(i)
            }
        }
        
        var pred = [Int]()
        var dist = [Int]()

        if !g.bfs(starts: starts, pred: &pred, dist: &dist) {
            return -1
        }

        return dist[g.end]
    }
    
    class Graph {
        let width: Int
        let height: Int
        let topos: [UInt8]
        let start: Int
        let end: Int
        var adj: [[Int]]
        
        var v: Int {
            adj.count
        }
        
        init(_ input: [Substring]) {
            width = input.first!.count
            height = input.count
            adj = Array(0..<width*height).map{ _ in [Int]() }
         
            var arr = [UInt8]()
            var s = 0
            var e = 0
            
            for (y, line) in input.enumerated() {
                for (x, ch) in line.enumerated() {
                    var ch2 = ch

                    if ch == "S" {
                        s = y * width + x
                        ch2 = "a"
                    } else if ch == "E" {
                        e = y * width + x
                        ch2 = "z"
                    }
                    
                    arr.append(ch2.asciiValue!)
                }
            }
            
            topos = arr
            start = s
            end = e
            
            for (y, line) in input.enumerated() {
                for (x, _) in line.enumerated() {
                    let vertex = (x, y)
                    addEdge(vertex, neighbor: (x-1, y))
                    addEdge(vertex, neighbor: (x+1, y))
                    addEdge(vertex, neighbor: (x, y-1))
                    addEdge(vertex, neighbor: (x, y+1))
                }
            }
        }
        
        func addEdge(_ vertex: (Int, Int), neighbor: (Int, Int)) {
            if neighbor.0 < 0 || neighbor.0 >= width || neighbor.1 < 0 || neighbor.1 >= height {
                return
            }
            
            let vIdx = idx(vertex)
            let nIdx = idx(neighbor)
            
            if topos[vIdx] + 1 < topos[nIdx] {
                return
            }
            
            adj[vIdx].append(nIdx)
        }
        
        func idx(_ xy: (Int, Int)) -> Int {
            idx(x: xy.0, y: xy.1)
        }
        
        func idx(x: Int, y: Int) -> Int {
            y * width + x
        }
        
        func bfs(starts: [Int], pred: inout [Int], dist: inout [Int]) -> Bool {
            var queue = [Int](starts)
            var visited = [Bool](repeating: false, count: v)

            pred = [Int](repeating: -1, count: v)
            dist = [Int](repeating: Int.max, count: v)

            for start in starts {
                visited[start] = true
                dist[start] = 0
            }
            
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
                        return true
                    }
                }
            }
            
            return false
        }
    }
}
