import Foundation

public class day19: Puzzle {
    public private(set) var input = ""
  
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources.loadInput(resoureName: resourceName)
    }
    
    public func solve() -> String {
        return """
Part 1: \(part1())
Part 2: \(part2())
"""
    }
    
    public func part1() -> Int {
        let bps = day19.parse(input: input)
        var total = 0
        
        for bp in bps {
            let maxg = Simulator(timeLimit: 24).execute(bp)
            print("\(bp.id): \(maxg)")
            total += maxg * bp.id
        }
        
        return total
    }
    
    public func part2() -> Int {
        return -1
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
    
    struct State: CustomStringConvertible {
        var time: Int
        var materials: Materials
        var robots: [String: Int]
        var robotBuilt: String
        var cost: Materials
        var extra: String
        var timeAdded: Int
        
        init(time: Int, materials: Materials, robots: [String : Int], robotBuilt: String, cost: Materials, extra: String = "", timeAdded: Int = 1) {
            self.time = time
            self.materials = materials
            self.robots = robots
            self.robotBuilt = robotBuilt
            self.cost = cost
            self.extra = extra
            self.timeAdded = timeAdded
        }
        
        var description: String {
            "\(extra)State time=\(time) materials=\(materials) robots=\(robots) robotBuilt=\(robotBuilt) cost=\(cost)"
        }
        
        var robotTypes: Set<String> {
            Set(robots.filter{ $0.value > 0 }.keys)
        }
        
        func next(addTime: Int) -> State {
            var nextMaterials = materials
            
            for (type, count) in robots {
                nextMaterials[type] = (nextMaterials[type] ?? 0) + (count * addTime)
            }

            return State(time: time+addTime, materials: nextMaterials, robots: robots, robotBuilt: "", cost: Materials(), extra: description + "\n")
        }

        func next(addTime: Int, robotType: String, cost: Materials) -> State {
            var nextMaterials = materials - cost
            var nextRobots = robots
            
            for (type, count) in robots {
                nextMaterials[type] = (nextMaterials[type] ?? 0) + (count * addTime)
            }

            nextRobots[robotType] = (nextRobots[robotType] ?? 0) + 1

            return State(time: time+addTime, materials: nextMaterials, robots: nextRobots, robotBuilt: robotType, cost: cost, extra: description + "\n", timeAdded: addTime)
        }
    }
    
    class Simulator {
        let timeLimit: Int
        
        init(timeLimit: Int) {
            self.timeLimit = timeLimit
        }
        
        func execute(_ bp: Blueprint) -> Int {
            let state = State(time: 1, materials: ["ore": 1], robots: ["ore": 1], robotBuilt: "", cost: Materials())
            
            var maxg = 0
            var maxState = state
            
            var q = [state]
            
            while !q.isEmpty {
                let s = q.removeFirst()
                
                let this = s.materials["geode"] ?? 0
                
                if this > maxg {
                    maxg = this
                    maxState = s
                }
                
                var next = tick(bp: bp, s: s)
                
                if next.isEmpty && s.time < timeLimit {
                    //todo: needed?
                    next.append(s.next(addTime: timeLimit - s.time))
                }
                
                q.append(contentsOf: next)
            }
            
            print(maxState)
            return maxg
        }
        
        func tick(bp: Blueprint, s: State) -> [State] {
            var states = [State]()

            appendStates(bp: bp, s: s, results: &states)
            
            return states
        }
        
        func appendStates(bp: Blueprint, s: State, results: inout [State]) {
            for (robotType, cost) in bp.costs {
                let makeable = Set(s.robotTypes).intersection(cost.keys)
                
                if makeable.count < cost.count {
                    continue
                }
         
                let neededMaterials = (s.materials - cost)
                    .filter{ $0.value < 0 }
                
                let timeToBuild = neededMaterials
                    .map { abs($0.value) / s.robots[$0.key]! + min(1, abs($0.value) % s.robots[$0.key]!) + 1 }

                if let addTime = timeToBuild.max(by: { $0 < $1 }) {
                    if s.time + addTime > timeLimit {
                        continue
                    }
                    let ns = s.next(addTime: addTime, robotType: robotType, cost: cost)
                    results.append(ns)
                } else {
                    
                    //todo: only add if path is not visited
                    if s.timeAdded == 1 || s.time + 1 > timeLimit {
                        continue
                    }
                    
                    let ns = s.next(addTime: 1, robotType: robotType, cost: cost)
                    results.append(ns)
                }
            }
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
