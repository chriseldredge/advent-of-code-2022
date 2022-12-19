import Foundation

public class day18: Puzzle {
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
        let points = Set<Point>(day18.parse(input: input))
        
        var adj = 0
        
        for p in points {
            if points.contains(p.translate(dx: 1)) {
                adj += 1
            }
            if points.contains(p.translate(dy: 1)) {
                adj += 1
            }
            if points.contains(p.translate(dz: 1)) {
                adj += 1
            }
        }
        
        return points.count * 6 - adj * 2
    }
    
    public func part2() -> Int {
        let points = Set<Point>(day18.parse(input: input).map{ $0.translate(dx: 1, dy: 1, dz: 1)})
        
        if points.contains(Point("0,0,0")) {
            fatalError()
        }

        var filled = Set<Point>()
        var q = [Point]()
        
        var area = 0
        
        q.append(Point("0,0,0"))
        
        let t = [
            (dx: 1, dy: 0, dz: 0),
            (dx: -1, dy: 0, dz: 0),
            (dx: 0, dy: 1, dz: 0),
            (dx: 0, dy: -1, dz: 0),
            (dx: 0, dy: 0, dz: 1),
            (dx: 0, dy: 0, dz: -1),
        ]
        
        while !q.isEmpty {
            let p = q.removeFirst()
            
            if p.x < 0 || p.y < 0 || p.z < 0 || p.x > 23 || p.y > 23 || p.z > 23 {
                continue
            }
            
            if filled.contains(p) {
                continue
            }
            
            filled.insert(p)
            
            for d in t {
                let n = p.translate(d: d)
                if points.contains(n) {
                    area += 1
                } else {
                    q.append(n)
                }
            }
        }
        
        return area
    }

    static func parse(input: [Substring]) -> [Point] {
        input.map(Point.init)
    }
    
    struct Point: Comparable, Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        let z: Int
        
        init(x: Int, y: Int, z: Int) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        init(_ xyz: Substring) {
            let parts = xyz.components(separatedBy: ",")
            self.init(x: Int(parts[0])!, y: Int(parts[1])!, z: Int(parts[2])!)
        }
                
        var description: String {
            return "(x: \(x), y: \(y), z: \(z))"
        }

        func translate(dx: Int = 0, dy: Int = 0, dz: Int = 0) -> Point {
            Point(x: x+dx, y: y+dy, z: z+dz)
        }

        func translate(d: (dx: Int, dy: Int, dz: Int)) -> Point {
            Point(x: x+d.dx, y: y+d.dy, z: z+d.dz)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(x)
            hasher.combine(y)
            hasher.combine(z)
        }
        
        static func < (lhs: Point, rhs: Point) -> Bool {
            lhs.x < rhs.x || lhs.y < rhs.y || lhs.z < rhs.z
        }
        
        static func == (lhs: Point, rhs: Point) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
        }
    }
}
