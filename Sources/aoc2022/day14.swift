import Foundation

public class day14: Puzzle {
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
        return day14.parseGrid(input: self.input).dropSand()
    }
    
    public func part2() -> Int {
        let g = day14.parseGrid(input: self.input)
        let bottom = g.cells.map{ $0.y }.max()! + 2
        
        g.addRock(from: Point(x: 0, y: bottom), through: Point(x: 1000, y: bottom))
        return g.dropSand()
    }
    
    static func parseGrid(input: [Substring]) -> SandGrid {
        let grid = SandGrid()
        
        for segments in input {
            let points = segments.components(separatedBy: " -> ")
            for idx in 0..<points.count-1 {
                let a = Point(points[idx])
                let b = Point(points[idx+1])
                grid.addRock(from: a, through: b)
            }
        }
        
        return grid
    }

    class SandGrid {
        var cells = Set<Point>()
        
        func addRock(from: Point, through: Point) {
            for p in Line(from: from, through: through) {
                cells.insert(p)
            }
        }
        
        func dropSand(_ origin: Point = Point(x: 500, y: 0)) -> Int {
            let w = cells.map{ $0.x }.max()!
            let h = cells.map{ $0.y }.max()!
            
            var arr = [[Int]]()
            for _ in 0...h {
                arr.append([Int](repeating: 0, count: w+1))
            }
            
            for p in cells {
                arr[p.y][p.x] = 1
            }
            
            var count = 0
            var gx = origin.x
            var gy = origin.y
            
            while gy < h && gx > 0 && gx < w && arr[origin.y][origin.x] == 0 {
                if arr[gy+1][gx] == 0 {
                    gy += 1
                } else if arr[gy+1][gx-1] == 0 {
                    gy += 1
                    gx -= 1
                } else if arr[gy+1][gx+1] == 0 {
                    gy += 1
                    gx += 1
                } else {
                    arr[gy][gx] = 2
                    gx = origin.x
                    gy = origin.y
                    count += 1
                }
            }

            return count
        }
    }
    
    struct Point: Comparable, Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        init(_ xy: String) {
            let parts = xy.components(separatedBy: ",")
            self.init(x: Int(parts.first!)!, y: Int(parts.last!)!)
        }
        
        var description: String {
            return "(x: \(x), y: \(y))"
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(x)
            hasher.combine(y)
        }
        
        static func < (lhs: Point, rhs: Point) -> Bool {
            lhs.x < rhs.x || lhs.y < rhs.y
        }
        
        static func == (lhs: Point, rhs: Point) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
    
    struct Line : Sequence {
        let from: Point
        let through: Point
        
        init(from: Point, through: Point) {
            self.from = from
            self.through = through
        }
        
        func makeIterator() -> PointIterator {
            PointIterator(from: from, through: through)
        }
    }
    
    struct PointIterator: IteratorProtocol {
        typealias Element = Point
        
        let from: Point
        let through: Point
        let dx: Int
        let dy: Int

        var pos: Point?
        
        init(from: Point, through: Point) {
            self.from = from
            self.through = through
            self.dx = min(max(through.x - from.x, -1), 1)
            self.dy = min(max(through.y - from.y, -1), 1)
            pos = from
        }
        
        mutating func next() -> Point? {
            if let tmp = pos {
                if tmp == through {
                    pos = nil
                } else {
                    pos = Point(x: tmp.x + dx, y: tmp.y + dy)
                }
                return tmp
            }
            return nil
        }
    }
}


