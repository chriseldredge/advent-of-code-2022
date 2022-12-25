import Foundation

public class day24: Puzzle {
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
        let basin = parse()
        
        return basin.shortestPath(startingPoint: basin.startingPoint, goal: basin.goal)
    }
    
    public func part2() -> Int {
        let basin = parse()
        
        let a = basin.shortestPath(startingPoint: basin.startingPoint, goal: basin.goal)
        let b = basin.shortestPath(startingPoint: basin.goal, goal: basin.startingPoint, iter: a+1)
        let c = basin.shortestPath(startingPoint: basin.startingPoint, goal: basin.goal, iter: b+1)
        
        print("\(a), \(b), \(c)")
        return c
    }
    
    public func parse() -> Basin {
        var points = Set<Vec>()
        var start: Point? = nil
        var end: Point? = nil

        let dirs: [Character: (Int, Int)] = [
            "<": (-1, 0),
            ">": (1, 0),
            "^": (0, -1),
            "v": (0, 1),
        ]
        
        for (y, line) in input.enumerated() {
            for (x, ch) in line.enumerated() {
                if ch ==  "." {
                    if start == nil {
                        start = Point(x: x-1, y: y-1)
                    }
                    end = Point(x: x-1, y: y-1)
                } else if let dir = dirs[ch] {
                    points.insert(Vec(position: Point(x: x-1, y: y-1), direction: dir))
                }
            }
        }
        
        let width = input.first!.count - 2
        let height = input.count - 2
        
        return Basin(blizzards: points, startingPoint: start!, goal: end!, width: width, height: height)
    }
    
    struct State: Hashable {
        let position: Point
        let iter: Int
        
        init(position: Point, iter: Int) {
            self.position = position
            self.iter = iter
       }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(position)
            hasher.combine(iter)
        }
    }
    
    public class Basin {
        let blizzards: Set<Vec>
        let startingPoint: Point
        let goal: Point
        let width: Int
        let height: Int
        let openSpaces: [Int: Set<Point>]
        
        public init(blizzards: Set<Vec>, startingPoint: Point, goal: Point, width: Int, height: Int) {
            self.blizzards = blizzards
            self.startingPoint = startingPoint
            self.goal = goal
            self.width = width
            self.height = height
            self.openSpaces = Basin.computeOpenSpaces(
                blizzards: blizzards, startingPoint: startingPoint, goal: goal, width: width, height: height)
        }
        
        func next(position: Point, iter: Int) -> [State] {
            let nextIter = (iter+1) % openSpaces.count
            var next = openSpaces[nextIter]!
                .intersection([
                    (-1, 0),
                    (1, 0),
                    (0, -1),
                    (0, 1),
                ].map(position.translate)
                ).map{ State(position: $0, iter: iter+1) }
            
            if openSpaces[nextIter]!.contains(position) {
                next.append(State(position: position, iter: iter+1))
            }
            
            return next
        }

        func shortestPath(startingPoint: Point, goal: Point, iter: Int = 0) -> Int {
            var q = [State(position: startingPoint, iter: iter)]
            
            var i = 0

            while !q.isEmpty {
                var nextQ = Set<State>()
                //print("i=\(i), states=\(q.count), open=\(openSpaces[i]!.count)")
                i += 1
                for s in q {
                    if s.position == goal {
                        return s.iter
                    }

                    for ns in next(position: s.position, iter: s.iter) {
                        nextQ.insert(ns)
                    }
                }
                
                q = Array(nextQ)
            }
            
            return -1
        }

        func distanceToGoal(_ p: Point) -> Int {
            abs(goal.x - p.x) + abs(goal.y - p.y)
        }
        
        static func computeOpenSpaces(blizzards: Set<Vec>, startingPoint: Point, goal: Point, width: Int, height: Int) -> [Int: Set<Point>] {
            var spaces = [Int: Set<Point>]()
            var all = Set<Point>()
            
            for y in 0..<height {
                for x in 0..<width {
                    all.insert(Point(x: x, y: y))
                }
            }
            
            for i in 0..<width*height {
                var iterBlizzards = Set<Point>()
                for b in blizzards {
                    var px = (b.position.x + b.direction.0*i) % width
                    var py = (b.position.y + b.direction.1*i) % height
                    
                    if px < 0 {
                        px += width
                    } else if py < 0 {
                        py += height
                    }
                    
                    iterBlizzards.insert(Point(x: px, y: py))
                }

                spaces[i] = all.subtracting(iterBlizzards).union([startingPoint, goal])
            }
            
            return spaces
        }
    }
    
    public struct Vec: Hashable {
        let position: Point
        let direction: (Int, Int)
        
        public init(position: Point, direction: (Int, Int)) {
            self.position = position
            self.direction = direction
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(position)
            hasher.combine(direction.0)
            hasher.combine(direction.1)
        }
        
        public static func == (lhs: Vec, rhs: Vec) -> Bool {
            lhs.position == rhs.position && lhs.direction == rhs.direction
        }
    }
    
    public struct Point: Hashable, CustomStringConvertible {
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
        
        public static func == (lhs: Point, rhs: Point) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
}
