import Foundation

public class day23: Puzzle {
    public private(set) var input = [Substring]()
  
    var ticks = 0
    let dirs = ["n", "s", "w", "e"]
    
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
        var points = parse()
        
        for _ in 0..<10 {
            let next = tick(points)
            points = next
        }
        
        return countEmpty(points)
    }
    
    public func part2() -> Int {
        var points = parse()

        ticks = 0

        for _ in 0..<1000 {
            let next = tick(points)
            if next == points {
                return ticks
            }
            points = next
        }
        
        fatalError()
    }
    
    func tick(_ points: Set<Point>) -> Set<Point> {
        let toMove = points.filter{ hasNeighbor($0, points) }
        let happy = points.subtracting(toMove)
        var stuck = Set<Point>()
        var proposed = [Point: Set<Point>]()
        
        for p in toMove {
            if let to = proposeMove(p, points) {
                if let c = proposed[to] {
                    proposed[to] = c.union([p])
                } else {
                    proposed[to] = Set([p])
                }
            } else {
                stuck.insert(p)
            }
        }
        
        let collisions = proposed
            .filter{ $0.value.count > 1 }
            .compactMap{ $0.value }
            .reduce(Set<Point>(), { $0.union($1) })
        
        let moved = proposed
            .filter{ $0.value.count == 1 }

        let result = happy.union(stuck).union(collisions).union(moved.keys)

        assert(result.count == points.count)
        ticks += 1
        return result
    }

    func proposeMove(_ p: Point, _ points: Set<Point>) -> Point? {
        for i in 0..<4 {
            let d = dirs[(ticks + i) % dirs.count]
            let compasses = Compass.allCases
                .filter{ $0.rawValue.contains(d) }

            if !hasNeighbor(p, points, compases: compasses) {
                return p.translate(compasses.first(where: {$0.rawValue == d})!.tup)
            }
        }
        return nil
    }
    
    enum Compass: String, CaseIterable {
        case ne, n, nw, w, sw, s, se, e
        
        var tup: (Int, Int) {
            switch self {
            case .ne:
                return (1, -1)
            case .n:
                return (0, -1)
            case .nw:
                return (-1, -1)
            case .w:
                return (-1, 0)
            case .sw:
                return (-1, 1)
            case .s:
                return (0, 1)
            case .se:
                return (1, 1)
            case .e:
                return (1, 0)
            }
        }
    }
    
    func hasNeighbor(_ p: Point, _ points: Set<Point>, compases: [Compass] = Compass.allCases) -> Bool {
        return !points.intersection(compases.map(\.tup).map(p.translate)).isEmpty
    }
    
    func countEmpty(_ points: Set<Point>) -> Int {
        let xs = points.min(by: { $0.x < $1.x })!.x
        let xe = points.max(by: { $0.x < $1.x })!.x
        let ys = points.min(by: { $0.y < $1.y })!.y
        let ye = points.max(by: { $0.y < $1.y })!.y

        let area = (xe - xs + 1) * (ye - ys + 1)
        print("x=\(xs)...\(xe) y=\(ys)...\(ye) area=\(area) count=\(points.count)")

        return area - points.count
    }
    
    func parse() -> Set<Point> {
        var points = Set<Point>()
        
        for (y, line) in input.enumerated() {
            for (x, ch) in line.enumerated() {
                if ch == "#" {
                    points.insert(Point(x: x, y: y))
                }
            }
        }
        
        return points
    }
    
    public struct Point: Comparable, Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        
        public init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        func translate(dx: Int = 0, dy: Int = 0) -> Point {
            Point(x: self.x + dx, y: self.y + dy)
        }
        
        func translate(_ tup: (Int, Int)) -> Point {
            Point(x: self.x + tup.0, y: self.y + tup.1)
        }
        
        public var description: String {
            return "(x: \(x), y: \(y))"
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(x)
            hasher.combine(y)
        }
        
        public static func < (lhs: Point, rhs: Point) -> Bool {
            lhs.x < rhs.x || lhs.y < rhs.y
        }
        
        public static func == (lhs: Point, rhs: Point) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
}
