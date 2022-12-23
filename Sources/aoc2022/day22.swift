import Foundation

public class day22: Puzzle {
    public var input = [Substring]()
  
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName, omittingEmptySubsequences: false)
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
    }

    public func part1() -> Int {
        let (map, path) = parse()
        
        return Solver(map: map).solve(path: path)
    }
    
    public func part2() -> Int {
        let (map, path) = parse()
        
        return CubeSolver(map: map).solve(path: path)
    }
    
    public func parse() -> (Map, Path) {
        var index = -1
        var first: Point? = nil
        
        var walls = Set<Point>()
        var open = Set<Point>()
        
        for (y, line) in input.enumerated() {
            if line == "" {
                index = y
                break
            }
        
            for (x, ch) in line.enumerated() {
                let p = Point(x: x, y: y)
                if ch == "#" {
                    walls.insert(p)
                } else if ch == "." {
                    if first == nil {
                        first = p
                    }
                    open.insert(p)
                }
            }
        }
        
        return (Map(open: open, walls: walls, startingPoint: first!), Path(input[index+1]))
    }
    
    public typealias Facing = (Int, Int)
    
    public class Solver {
        let map: Map
        
        public init(map: Map) {
            self.map = map
        }
        
        public let facings = [
            (1, 0),
            (0, 1),
            (-1, 0),
            (0, -1)
        ]
        
        public var facingIndex = 0
        
        public var facing: Facing {
            facings[facingIndex]
        }
        
        public func solve(path: Path) -> Int {
            var position = map.startingPoint
            
            for m in path {
                switch m {
                case .Turn(let direction):
                    facingIndex = (facingIndex + direction + facings.count) % facings.count
                case .Step(let steps):
                    for _ in 0..<steps {
                        let next = nextPosition(position)
                        
                        if map.walls.contains(next) {
                            break
                        }
                        
                        position = next
                    }
                }
            }
            
            let row = position.y + 1
            let col = position.x + 1
            let answer = 1000 * row + 4 * col + facingIndex
            return answer
        }
        
        public func nextPosition(_ position: Point) -> Point {
            var next = position.translate(dx: facing.0,  dy: facing.1)
            
            if map.valid(next) {
                return next
            }
            
            var strideX = stride(from: position.x, through: position.x, by: 1)
            var strideY = stride(from: position.y, through: position.y, by: 1)
            
            if facing.0 == 1 {
                strideX = stride(from: 0, through: position.x-1, by: 1)
            } else if facing.1 == 1 {
                strideY = stride(from: 0, through: position.y-1, by: 1)
            } else if facing.0 == -1 {
                strideX = stride(from: 200, through: position.x+1, by: -1)
            } else if facing.1 == -1 {
                strideY = stride(from: 200, through: position.y+1, by: -1)
            }
            
        stride:
            for y in strideY {
                for x in strideX {
                    next = Point(x: x, y: y)
                    if map.valid(next) {
                        break stride
                    }
                }
            }
            
            return next
        }
    }
    
    public class CubeSolver: Solver {
        var transitions = [
            0: [Point: (Point, Int)](),
            1: [Point: (Point, Int)](),
            2: [Point: (Point, Int)](),
            3: [Point: (Point, Int)](),
        ]
        
        public override init(map: Map) {
            for c in 0..<50 {
                // A..F
                transitions[3]![Point(x: c + 50, y: 0)] = (Point(x: 0, y: 150 + c), 0)
                transitions[2]![Point(x: 0, y: c + 150)] = (Point(x: 50 + c, y: 0), 1)

                // E..A
                transitions[2]![Point(x: 0, y: 100 + c)] = (Point(x: 50, y: 49 - c), 0)
                transitions[2]![Point(x: 50, y: c)] = (Point(x: 0, y: 149 - c), 0)

                // B..D
                transitions[0]![Point(x: 149, y: c)] = (Point(x: 99, y: 149 - c), 2)
                transitions[0]![Point(x: 99, y: 100 + c)] = (Point(x: 149, y: 49 - c), 2)

                // C..E
                transitions[2]![Point(x: 50, y: 50 + c)] = (Point(x: c, y: 100), 1)
                transitions[3]![Point(x: c, y: 100)] = (Point(x: 50, y: 50 + c), 0)

                // B..C
                transitions[1]![Point(x: 100 + c, y: 49)] = (Point(x: 99, y: 50 + c), 2)
                transitions[0]![Point(x: 99, y: 50 + c)] = (Point(x: 100 + c, y: 49), 3)

                // D..F
                transitions[1]![Point(x: 50 + c, y: 149)] = (Point(x: 49, y: 150 + c), 2)
                transitions[0]![Point(x: 49, y: 150 + c)] = (Point(x: 50 + c, y: 149), 3)
                
                // B..F
                transitions[3]![Point(x: 100 + c, y: 0)] = (Point(x: c, y: 199), 3)
                transitions[1]![Point(x: c, y: 199)] = (Point(x: 100 + c, y: 0), 1)
            }
            super.init(map: map)
        }
        
        public override func nextPosition(_ position: day22.Point) -> day22.Point {
            let next = position.translate(dx: facing.0,  dy: facing.1)
            
            if map.valid(next) {
                return next
            }

            if let (tp, tf) = transitions[facingIndex]?[position] {
                if map.open.contains(tp) {
                    facingIndex = tf
                }
                print("Move from \(position) to \(tp) facing \(facing)")

                return tp
            }
            
            fatalError("No link from \(position)")
        }
    }
    
    public class Map {
        let open: Set<Point>
        let walls: Set<Point>
        public let startingPoint: Point
        
        public init(open: Set<Point>, walls: Set<Point>, startingPoint: Point) {
            self.open = open
            self.walls = walls
            self.startingPoint = startingPoint
        }
        
        func valid(_ p: Point) -> Bool {
            open.contains(p) || walls.contains(p)
        }
    }
    
    public enum Move {
        case Step(Int), Turn(Int)
    }
    
    public struct Path: Sequence, IteratorProtocol {
        public typealias Element = Move
        public typealias Iterator = Path
        
        let seq: Substring
        var i = 0
        
        public init(_ seq: Substring) {
            self.seq = seq
        }

        public func makeIterator() -> Path {
            return self
        }

        public mutating func next() -> Move? {
            if i == seq.count {
                return nil
            }

            var next: Move? = nil
            let index = seq.index(seq.startIndex, offsetBy: i)
            var c = 1
            
            if seq[index] == "L" {
                next = Move.Turn(-1)
            } else if seq[index] == "R" {
                next = Move.Turn(1)
            } else {
                while i+c < seq.count && seq[seq.index(index, offsetBy: c)].isNumber {
                    c += 1
                }
                
                let steps = seq[index...seq.index(index, offsetBy: c-1)]
                next = Move.Step(Int(steps)!)
            }
            
            i += c
            return next
        }
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
