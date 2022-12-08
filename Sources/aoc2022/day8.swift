import Foundation

class day8: Puzzle {
    let input: [Substring]
    
    public init(input: [Substring]) {
        self.input = input
    }
    
    public convenience init() {
        self.init(input: day8.load())
    }
 
    func solve() -> String {
        return """
Part 1: \(part1())
Part 2: \(part2())
"""
    }
    
    func part1() -> Int {
        TopoGrid(input: input).countVisible()
    }
    
    func part2() -> Int {
        TopoGrid(input: input).findBestScenicScore()
    }
    
    public static func load(resourceName: String = "day8") -> [Substring] {
        Resources.loadLines(resoureName: resourceName)
    }
}

public class TopoGrid {
    let cells: [[UInt8]]
    
    public var width: Int {
        cells.first!.count
    }
    
    public var height: Int {
        cells.count
    }
    
    public init(input: [Substring]) {
        cells = input.map{ (line) in
            Array(line).map{ UInt8(String($0))! }
        }
    }
    
    public func countVisible() -> Int {
        var count = width * 2 + height * 2 - 4

        for y in cells.innerRange {
            for x in cells.first!.innerRange {
                if visible(x: x, y: y) {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func visible(x: Int, y: Int) -> Bool {
        let v = cells[y][x]
        let maxLeft = cells[y][0..<x].max()!
        let maxRight = cells[y][x+1..<width].max()!
        let maxTop = cells[0..<y].map{ $0[x] }.max()!
        let maxBottom = cells[y+1..<height].map{ $0[x] }.max()!
        
        let visible = min(maxLeft, maxRight, maxTop, maxBottom) < v

        return visible
    }
    
    public func findBestScenicScore() -> Int {
        var best = 0
        
        for y in cells.innerRange {
            for x in cells.first!.innerRange {
                best = max(best, scenicScore(x: x, y: y))
            }
        }

        return best
    }
    
    func countVisible<S1: Sequence, S2: Sequence>(xs: S1, ys: S2, topoHeight: UInt8) -> Int where S1.Element == Int, S2.Element == Int {
        var asTallFound = false
        
        let count = xs.lazy
            .map{ (x) in
                ys.lazy.map{ (y) in (x: x, y: y) }
            }
            .flatMap{ $0 }
            .map{ coord in self.cells[coord.y][coord.x] }
            .prefix(while: { otherHeight in
                asTallFound = otherHeight >= topoHeight
                return !asTallFound
            })
            .count
        
        return count + (asTallFound ? 1 : 0)
    }
    
    func scenicScore(x: Int, y: Int) -> Int {
        let topoHeight = cells[y][x]
        
        let xs = x...x
        let ys = y...y
        
        let numVisAbove = countVisible(xs: xs, ys: stride(from: y-1, through: 0, by: -1), topoHeight: topoHeight)
        let numVisBelow = countVisible(xs: xs, ys: y+1..<height, topoHeight: topoHeight)
        let numVisLeft  = countVisible(xs: stride(from: x-1, through: 0, by: -1), ys: ys, topoHeight: topoHeight)
        let numVisRight = countVisible(xs: x+1..<width, ys: ys, topoHeight: topoHeight)

        let score = numVisAbove*numVisBelow*numVisLeft*numVisRight
        
        //print("(x: \(x), y: \(y)) v=\(topoHeight), score=\(score) \(numVisAbove) \(numVisBelow) \(numVisLeft) \(numVisRight)")
        
        return score
    }
}

extension Array {
    var innerRange: Range<Int> {
        self.index(self.startIndex, offsetBy: 1)..<self.index(self.endIndex, offsetBy: -1)
    }
}
