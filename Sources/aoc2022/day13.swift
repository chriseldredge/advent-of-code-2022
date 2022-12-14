import Foundation

public class day13: Puzzle {
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
        let packets = input.map(day13.parsePacket)
        var sum = 0
        
        for index in stride(from: packets.startIndex, to: packets.endIndex, by: 2) {
            let lhs = packets[index]
            let rhs = packets[index+1]
            let pairIndex = (index/2)+1
            
            if lhs < rhs {
                sum += pairIndex
            }
        }
        return sum
    }
    
    public func part2() -> Int {
        let packets = input.map(day13.parsePacket)
        let a = IntListInt(2)
        let b = IntListInt(6)
        
        let sorted = [packets, [a, b]].joined().sorted()
        let aPos = sorted.firstIndex(of: a)! + 1
        let bPos = sorted.firstIndex(of: b)! + 1

        return aPos * bPos
    }
    
    static func parsePacket(line: Substring) -> IntList {
        var stack = [IntList]()
        var cur = IntList()
        var numStr = ""
        
        for ch in line {
            switch ch {
            case "[":
                stack.append(cur)
                cur = IntList()
                break
            case "]":
                if !numStr.isEmpty {
                    cur.append(IntListInt(Int(numStr)!))
                    numStr = ""
                }
                let tmp = cur
                cur = stack.removeLast()
                cur.append(tmp)
                break
            case ",":
                if !numStr.isEmpty {
                    cur.append(IntListInt(Int(numStr)!))
                    numStr = ""
                }
                break
            default:
                numStr.append(ch)
                break
            }
        }
        
        return cur.unwrap()
    }
}

public class IntList: Comparable, CustomStringConvertible {
    private var data = [IntList]()
    private var val: Int? = nil
    
    public convenience init(_ item: IntList) {
        self.init()
        append(item)
    }
    
    public func append(_ item: IntList) {
        if val != nil {
            fatalError()
        }
        data.append(item)
    }
    
    public func put(_ val: Int) {
        if data.isEmpty && self.val == nil {
            self.val = val
            return
        }
        fatalError()
    }
    
    public var count: Int {
        data.count
    }

    public var description: String {
        val?.description ?? data.description
    }
    
    public func unwrap() -> IntList {
        if data.count != 1 {
            fatalError("cannot unwrap when count=\(data.count)")
        }
        return data.first!
    }
    
    public static func < (lhs: IntList, rhs: IntList) -> Bool {
        //print("Comparing \(lhs) vs \(rhs)")
        if lhs.val != nil {
            if rhs.val != nil {
                return lhs.val! < rhs.val!
            }
            
            let wrap = IntList(lhs)
            return wrap < rhs
        }
        
        if rhs.val != nil {
            let wrap = IntList(rhs)
            return lhs < wrap
        }

        for (l, r) in zip(lhs.data, rhs.data) {
            if l < r {
                return true
            }
            if r < l {
                return false
            }
        }
        
        return lhs.count < rhs.count
    }
    
    public static func == (lhs: IntList, rhs: IntList) -> Bool {
        lhs === rhs
    }
}

public class IntListInt: IntList {
    convenience init(_ val: Int) {
        self.init()
        put(val)
    }
}
