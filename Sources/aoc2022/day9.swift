import Foundation

class day9: Puzzle {
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

    func part1() -> Int {
        let sim = Sim(n: 2)
        for line in input {
            let parts = line.components(separatedBy: .whitespaces)
            sim.move(direction: parts[0], times: Int(parts[1])!)
        }
        return sim.visited.count
    }
    
    func part2() -> Int {
        let sim = Sim(n: 10, x: 11, y: 5)
        //print("== Initial State ==")
        for line in input {
//            sim.printMap(size: 26)
//            sim.printVisited(size: 26)
//            print("== \(line) ==")
            let parts = line.components(separatedBy: .whitespaces)
            sim.move(direction: parts[0], times: Int(parts[1])!)
        }
        
        //sim.printVisited(size: 26)
        return sim.visited.count
    }
    
    public class Sim {
        var knots: [Coordinate]
        var visited = Set<Coordinate>()
        
        let directions = ["R": (1, 0), "L": (-1, 0), "U": (0, 1), "D": (0, -1)]
        
        var head: Coordinate {
            knots.first!
        }

        var tail: Coordinate {
            knots.last!
        }
        
        init(n: Int, x: Int = 0, y: Int = 0) {
            self.knots = [Coordinate](repeating: Coordinate(x: x, y: y), count: n)
            self.visited.insert(tail)
        }
        
        func move(direction: String, times: Int) {
            let (dx, dy) = directions[direction]!

            for _ in 1...times {
                knots[0] = head.move(dx: dx, dy: dy)
                for i in 1..<knots.endIndex {
                    knots[i] = knots[i].follow(head: knots[i-1])
                }
                visited.insert(tail)
            }
        }
        
        func printMap(size: Int) {
            var map = [[Character]]()
            for _ in 1...size {
                map.append([Character](repeating: ".", count: size))
            }
            
            map[head.y][head.x] = "H"
            for (i, c) in knots[1...].enumerated() {
                if map[c.y][c.x] == "." {
                    let s = String(i+1)
                    map[c.y][c.x] = s[s.startIndex]
                }
            }
            
            map.reverse()
            
            for line in map {
                print(String(line))
            }
        }
        
        func printVisited(size: Int) {
            var map = [[Character]]()
            for _ in 1...size {
                map.append([Character](repeating: ".", count: size))
            }
            
            for c in visited {
                map[c.y][c.x] = "#"
            }
            
            map.reverse()
            
            for line in map {
                print(String(line))
            }
        }
    }
    
    struct Coordinate: Hashable {
        let x: Int
        let y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        func move(dx: Int = 0, dy: Int = 0) -> Coordinate {
            Coordinate(x: self.x + dx, y: self.y + dy)
        }
        
        func follow(head: Coordinate) -> Coordinate {
            let dx = abs(x - head.x)
            let dy = abs(y - head.y)
            
            if dx <= 1 && dy <= 1 {
                return self
            }
            
            var x = head.x
            var y = head.y
            
            if dx == 2 {
                x = (self.x + head.x) / 2
            }
            
            if dy == 2 {
                y = (self.y + head.y) / 2
            }
            
            return Coordinate(x: x, y: y)
        }
        
        static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(x)
            hasher.combine(y)
        }
    }
}
