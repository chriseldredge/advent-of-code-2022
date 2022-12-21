import Foundation

public class day2: Puzzle {
    var input = [Substring]()
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadLines(resoureName: resourceName)
    }
    
    public func solvePart1() -> String {
        return "\(self.scorePart1())"
    }
    
    public func solvePart2() -> String {
        return "\(self.scorePart2())"
    }

    public enum Shape: UInt8 {
        case rock, paper, scissors
        
        public var defeatedByShape: Shape {
            Shape(rawValue: (self.rawValue + 1) % 3)!
        }
        
        public var defeatsShape: Shape {
            Shape(rawValue: (self.rawValue + 2) % 3)!
        }
        
        public func defeats(other: Shape) -> Bool {
            self.defeatsShape == other
        }
        
        public func draw(other: Shape) -> Bool {
            self == other
        }
    }
    
    public struct Strat {
        let opponentShape: Shape
        let myShape: Shape
        
        init(opponentShape: Shape, myShape: Shape) {
            self.opponentShape = opponentShape
            self.myShape = myShape
        }
        
        func isTie() -> Bool {
            myShape == opponentShape
        }
        
        func isWin() -> Bool {
            return myShape.defeats(other: opponentShape)
        }
    }
    
    public func scorePart1() -> Int {
        day2.parse(input: input, day2.parseAsShape).map(self.scoreStrat).reduce(0, +)
    }
    
    public func scorePart2() -> Int {
        day2.parse(input: input, day2.parseAsCode).map(self.scoreStrat).reduce(0, +)
    }

    private func scoreStrat(strat: Strat) -> Int {
        var score = Int(strat.myShape.rawValue) + 1;
        
        if strat.isTie() {
            score += 3
        } else if strat.isWin() {
            score += 6
        }
        
        return score
    }
    
    private static func parseAsCode(code: Character, opponentShape: Shape) -> Shape {
        if code == "X" {
            return opponentShape.defeatsShape
        }
        
        if code == "Y" {
            return opponentShape
        }

        return opponentShape.defeatedByShape
    }

    private static func parseAsShape(code: Character, opponentShape: Shape) -> Shape {
        let x: Character = "X"

        return Shape(rawValue: code.asciiValue! - x.asciiValue!)!
    }
    
    private static func parse(input: [Substring], _ tfm: (Character, Shape) -> Shape) -> Array<Strat> {
        var list = [Strat]()
        
        for line in input {
            let a: Character = "A"
            let A = line[line.startIndex]
            let code = line[line.index(line.startIndex, offsetBy: 2)]
            
            let o = Shape(rawValue: A.asciiValue! - a.asciiValue!)!
            let m = tfm(code, o)
            list.append(Strat(opponentShape: o, myShape: m))
        }
        return list
    }
}
