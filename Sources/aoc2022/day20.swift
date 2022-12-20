import Foundation

public class day20: Puzzle {
    public private(set) var input = [Int]()
  
    var n: Int {
        input.count
    }
    
    public init() {
    }
    
    public func load(resourceName: String) {
        input = Resources
            .loadLines(resoureName: resourceName)
            .map { Int($0)! }
    }
    
    public func solve() -> String {
        return """
Part 1: \(part1())
Part 2: \(part2())
"""
    }
    
    public func part1() -> Int {
        solve()
    }
    
    public func part2() -> Int {
        solve(mul: 811589153, times: 10)
    }
    
    public func solve(mul: Int = 1, times: Int = 1) -> Int {
        let list = makeList(mul: mul)
        
        for _ in 1...times {
            for node in list {
                var steps = node.val % (n-1)
                
                if steps < 0 {
                    steps += n-1
                }
                
                var target = node
                
                for _ in 0..<steps {
                    target = target.next!
                }
                
                node.moveAfter(target)
            }
        }

        let result = Array(list.first!)
        let zeroPosition = result.firstIndex(of: 0)!
        
        let a = result[(zeroPosition + 1000) % n]
        let b = result[(zeroPosition + 2000) % n]
        let c = result[(zeroPosition + 3000) % n]

        print("\(a) + \(b) + \(c)")
        return a + b + c
    }
    
    func makeList(mul: Int = 1) -> [Node] {
        var list = [Node]()
        var prev: Node?
        
        for v in input {
            let node = Node(v * mul)
            list.append(node)
            prev?.append(next: node)
            prev = node
        }
        
        prev?.append(next: list.first!)
        
        return list
    }
    
    class Node: Sequence {
        typealias Element = Int
        
        let val: Int
        public private(set) var next: Node? = nil
        public private(set) var prev: Node? = nil

        func makeIterator() -> NodeIterator {
            NodeIterator(start: self)
        }
        
        init(_ val: Int) {
            self.val = val
        }
        
        func append(next: Node) {
            next.prev = self
            self.next = next
        }
        
        func remove() {
            next!.prev = prev
            prev!.next = next
            
            next = nil
            prev = nil
        }
        
        func moveAfter(_ node: Node) {
            guard node !== self else {
                return
            }
            
            remove()
            
            self.next = node.next
            self.prev = node
            
            node.next!.prev = self
            node.next = self
        }
    }
    
    struct NodeIterator: IteratorProtocol {
        typealias Element = Int

        let start: Node
        var cur: Node? = nil
        
        init(start: Node) {
            self.start = start
        }
        
        mutating func next() -> Int? {
            if cur == nil {
                cur = start
            } else if cur === start {
                return nil
            }
            
            let val = cur?.val
            cur = cur?.next
            return val
        }
        
    }
}
