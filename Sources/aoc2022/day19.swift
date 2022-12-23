import Foundation

public class day19: Puzzle {
    public private(set) var input = ""
  
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadInput(resoureName: resourceName)
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
    }

    public func part1() -> Int {
        let bps = day19.parse(input: input)
        var total = 0
        
        for bp in bps {
            let state = Simulator(timeLimit: 24).execute(bp)
            print("\(bp.id): \(state.score)")
            total += state.score * bp.id
        }
        
        return total
    }
    
    public func part2() -> Int {
        let bps = day19.parse(input: input)
        var total = 1
        
        for bp in bps[0..<3] {
            let state = Simulator(timeLimit: 32).execute(bp)
            print("\(bp.id): \(state.score)")
            total = total * state.score
        }
        
        return total
    }
    
    static func parse(input: String) -> [Blueprint] {
        let statements = input.components(separatedBy: .punctuationCharacters)
            .map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter{ !$0.isEmpty }

        var list = [Blueprint]()
        var cur = Blueprint(statements[0])
        
        for stmt in statements[1...] {
            if stmt.hasPrefix("Blueprint") {
                list.append(cur)
                cur = Blueprint(stmt)
            } else {
                cur.addRule(stmt)
            }
        }
        
        list.append(cur)
        return list
    }
    
    class Simulator {
        let timeLimit: Int

        init(timeLimit: Int) {
            self.timeLimit = timeLimit
        }
        
        func execute(_ bp: Blueprint, _ s: State = .Initial) -> State {
            var best = s
            var q = [s]

            while !q.isEmpty {
                var _q = [State]()
                for ns in q {
                    if ns.score > best.score {
                        best = ns
                    }
                    _q.append(contentsOf: tick(bp: bp, s: ns))
                }
                
                q = _q
            }
            
            return best
        }
        
        func tick(bp: Blueprint, s: State) -> [State] {
            var states = [State]()

            appendStates(bp: bp, s: s, results: &states)
            
            if states.isEmpty && s.time < timeLimit {
                states.append(s.next(addTime: timeLimit - s.time))
            }

            return states
        }
        
        func appendStates(bp: Blueprint, s: State, results: inout [State]) {
            for (robotType, cost) in bp.costs {
                let robotCount = s.robots[robotType] ?? 0
                
                if robotType != "geode" && robotCount == bp.maxNeeded(robotType) {
                    continue
                }
                
                let makeable = Set(s.robotTypes).intersection(cost.keys)
                
                if makeable.count < cost.count {
                    continue
                }
         
                let neededMaterials = (s.materials - cost)
                    .filter{ $0.value < 0 }
                
                let timeToBuild = neededMaterials
                    .map { abs($0.value) / s.robots[$0.key]! + min(1, abs($0.value) % s.robots[$0.key]!) + 1 }
                    .max(by: { $0 < $1 })
                
                let addTime = timeToBuild ?? 1
                
                if s.time + addTime > timeLimit {
                    continue
                }
                
                let ns = s.next(addTime: addTime, robotType: robotType, cost: cost)
                results.append(ns)
            }
        }
    }
    
    struct State: CustomStringConvertible, Hashable {
        var time: Int
        var materials: Materials
        var robots: [String: Int]
        
        static let Initial = State(time: 1, materials: ["ore": 1], robots: ["ore": 1])
        
        init(time: Int, materials: Materials, robots: [String : Int]) {
            self.time = time
            self.materials = materials
            self.robots = robots
        }
        
        var description: String {
            "State time=\(time) materials=\(materials) robots=\(robots)"
        }
        
        var score: Int {
            materials["geode"] ?? 0
        }
        
        var robotTypes: Set<String> {
            Set(robots.filter{ $0.value > 0 }.keys)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(time)
            hasher.combine(materials)
            hasher.combine(robots)
        }
        
        func next(addTime: Int) -> State {
            var nextMaterials = materials
            
            for (type, count) in robots {
                nextMaterials[type] = (nextMaterials[type] ?? 0) + (count * addTime)
            }

            return State(time: time+addTime, materials: nextMaterials, robots: robots)
        }

        func next(addTime: Int, robotType: String, cost: Materials) -> State {
            var nextMaterials = materials - cost
            var nextRobots = robots
            
            for (type, count) in robots {
                nextMaterials[type] = (nextMaterials[type] ?? 0) + (count * addTime)
            }

            nextRobots[robotType] = (nextRobots[robotType] ?? 0) + 1

            return State(time: time+addTime, materials: nextMaterials, robots: nextRobots)
        }
    }

    class Blueprint: CustomStringConvertible {
        let id: Int
        var costs = [String: Materials]()
        
        init(_ statement: String) {
            self.id = Int(statement.components(separatedBy: .whitespaces).last!)!
        }
        
        var description: String {
            "Blueprint \(id): \(costs)"
        }
        
        func maxNeeded(_ robotType: String) -> Int {
            costs.map{ (k, v) in v[robotType] ?? 0 }.max()!
        }
        
        func addRule(_ rule: String) {
            let words = rule.components(separatedBy: .whitespaces)
            
            guard words.count == 6 || words.count == 9 else {
                fatalError()
            }
            
            let type = words[1]
            var typeCost = [String: Int]()
            
            typeCost[words[5]] = Int(words[4])!
            
            if words.count == 9 {
                typeCost[words[8]] = Int(words[7])!
            }
            
            costs[type] = typeCost
        }
    }
}

public typealias Materials = [String: Int]

public extension Materials {
    static func >(lhs: Materials, rhs: Materials) -> Bool {
        for (k, qty) in rhs {
            if (lhs[k] ?? 0) < qty {
                return false
            }
        }
        
        return true
    }
    
    static func -(lhs: Materials, rhs: Materials) -> Materials {
        var result = Materials()
        
        for k in Set(lhs.keys).union(rhs.keys) {
            result[k] = (lhs[k] ?? 0) - (rhs[k] ?? 0)
        }
        
        return result
    }
}
