import Foundation

public class day17: Puzzle {
    public private(set) var input: Substring = ""
    
    var puffs = [Int]()
    var _puffCount = 0
    var nextPuff: Int {
        let next = puffs[_puffCount]
        _puffCount = (_puffCount + 1) % puffs.count
        return next
    }
    
    let shapes = [
        [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 2, y: 0), Point(x: 3, y: 0)],
        [Point(x: 0, y: 1), Point(x: 1, y: 1), Point(x: 2, y: 1), Point(x: 1, y: 0), Point(x: 1, y: 2)],
        [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 2, y: 0), Point(x: 2, y: 1), Point(x: 2, y: 2)],
        [Point(x: 0, y: 0), Point(x: 0, y: 1), Point(x: 0, y: 2), Point(x: 0, y: 3)],
        [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 0, y: 1), Point(x: 1, y: 1)],
    ]

    var _shapeCount = 0
    var nextShape: Shape {
        let next = shapes[_shapeCount]
        _shapeCount = (_shapeCount + 1) % shapes.count
        return Shape(points: next)
    }
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName).first!
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
    }

    public func part1() -> Int {
        _puffCount = 0
        _shapeCount = 0
        
        puffs = day17.parse(input: self.input)
        
        let grid = Grid()
        
        for _ in 1...2022 {
            let shape = nextShape
            
            grid.place(shape)

            move(grid: grid, shape: shape)
            
            grid.plop(shape)
        }
        
        return grid.height
    }
    
    public func part2() -> Int {
        _puffCount = 0
        _shapeCount = 0
        
        puffs = day17.parse(input: self.input)
        
        let grid = Grid()
        
        var deltas = [[[UInt8]]: (itr: Int, height: Int)]()

        for i in 0...(5*shapes.count*puffs.count) {
            if i > shapes.count*puffs.count {
                for s in stride(from: grid.rows.endIndex, through: shapes.count*puffs.count, by: -1) {
                    if test(grid: grid, s: s) {
                        let key = Array(grid.rows[s...])
                        if let (pi, pr) = deltas[key] {
                            let deltaRows = grid.height - pr
                            let deltaItr = i - pi
                            
                            let iters = 1000000000000
                            let repeatedBlockCount = (iters - pi) / deltaItr
                            let repeatedRowCount = repeatedBlockCount * deltaRows
                            
                            let rem = iters - (repeatedBlockCount * deltaItr) - pi
                            let crc = grid.height
                            
                            for _ in 1...rem {
                                let shape = nextShape

                                grid.place(shape)

                                move(grid: grid, shape: shape)

                                grid.plop(shape)
                            }
                            
                            return pr + repeatedRowCount + (grid.height - crc)
                        }
                        
                        deltas[key] = (itr: i, height: grid.height)
                        break
                    }
                }
            }

            let shape = nextShape

            grid.place(shape)

            move(grid: grid, shape: shape)

            grid.plop(shape)
        }

        for _ in 1...(5*shapes.count*puffs.count) {
            let shape = nextShape

            grid.place(shape)

            move(grid: grid, shape: shape)

            grid.plop(shape)
        }

        return 0
    }
    
    func test(grid: Grid, s: Int) -> Bool {
        let e = grid.rows.endIndex-1
        var i = 0
        
        while e - i > s && grid.rows[e - i] == grid.rows[s - i] {
            i += 1
        }
        
        return e - i == s && i > 5
    }
    
    func move(grid: Grid, shape: Shape) {
        while true {
            let dx = nextPuff
            
            if grid.valid(shape, dx: dx, dy: 0) {
                shape.translate(dx: dx)
            }
            
            if grid.valid(shape, dx: 0, dy: -1) {
                shape.translate(dy: -1)
            } else {
                break
            }
        }
    }
    
    static func parse(input: Substring) -> [Int] {
        input.map{ ch in ch == "<" ? -1 : 1 }
    }

    class Grid: CustomStringConvertible {
        let width = 7
        
        var rows = [[UInt8]]()
        
        init() {
        }
        
        var height: Int {
            rows.count
        }
        
        var description: String {
            rows.reversed()
                .compactMap { $0.map { $0 > 0 ? "#" : "."}.joined() }
                .joined(separator: "\n")
        }
        
        func place(_ shape: Shape) {
            shape.translate(dx: 2, dy: rows.count + 3)
        }
        
        func plop(_ shape: Shape) {
            for p in shape.points {
                while rows.count <= p.y {
                    addRow()
                }
                rows[p.y][p.x] = 2
            }
        }

        func valid(_ shape: Shape, dx: Int = 0, dy: Int = 0) -> Bool {
            let anyOutOfBounds = shape.points
                .first(where: { $0.x + dx < 0 || $0.x + dx >= 7 || $0.y + dy < 0 })
            
            if anyOutOfBounds != nil {
                return false
            }
            
            let anyCollision = shape.points
                .filter{ $0.y + dy < rows.count }
                .first(where: { rows[$0.y + dy][$0.x + dx] > 0 })
            
            if anyCollision != nil {
                return false
            }
            
            return true
        }
        
        private func addRow(repeating: UInt8 = 0) {
            rows.append([UInt8](repeating: repeating, count: width))
        }
    }
    
    class Shape {
        var points: [Point]
        
        init(points: [Point]) {
            self.points = points
        }
        
        public func translate(dx: Int = 0, dy: Int = 0) {
            points = points.map { $0.translate(dx: dx, dy: dy) }
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
        
        func translate(dx: Int = 0, dy: Int = 0) -> Point {
            Point(x: self.x + dx, y: self.y + dy)
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
}
