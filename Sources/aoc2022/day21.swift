import Foundation

public class day21: Puzzle {
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
        let kv = day21.parse(input: input)
            .map{ ($0.id, $0) }
        let exprs = Dictionary(uniqueKeysWithValues: kv)
        
        let root = exprs["root"]!
        
        root.resolve(exprs: exprs)
        
        return root.evaluate()!
    }
    
    public func part2() -> Int {
        let kv = day21.parse(input: input)
            .map{ ($0.id, $0) }
        var exprs = Dictionary(uniqueKeysWithValues: kv)
        
        exprs["humn"] = VariableExpression(id: "humn")
        
        if let root = exprs["root"]! as? ArithmeticExpression {
            root.resolve(exprs: exprs)
            return solveForX(left: root.left!.reduce(), right: root.right!.reduce())
         }
        
        return 0
    }
    
    func solveForX(left: Expression, right: Expression) -> Int {
        if let c = left as? ConstExpression {
            return solveForX(const: c, other: right)
        } else if let c = right as? ConstExpression {
            return solveForX(const: c, other: left)
        } else {
            fatalError("One side must be const")
        }
    }
    
    func solveForX(const: ConstExpression, other: Expression) -> Int {
        if let arithmetic = other as? ArithmeticExpression {
            let (nextConst, nextOther) = arithmetic.invert(other: const)
            return solveForX(const: nextConst, other: nextOther)
        }
        
        if other is VariableExpression {
            return const.value!
        }
        
        fatalError("\(other) is not VariableExpression or ArithmeticExpression")
    }
    
    static func parse(input: [Substring]) -> [Expression] {
        var list = [Expression]()
        
        for line in input {
            let words = line.components(separatedBy: .whitespaces)
            let id = words.first!.trimmingCharacters(in: .punctuationCharacters)
            var expr: Expression

            if words.count == 2 {
                expr = ConstExpression(id: id, value: Int(words.last!)!)
            } else {
                expr = ArithmeticExpression(id: id, operands: (words[1], words[3]), operation: Character(words[2]))
            }
            
            list.append(expr)
        }
        
        return list
    }

    class Expression {
        let id: String
        var value: Int?
        
        var resolved: Bool {
            value != nil
        }
        
        var deepDescription: String {
            if let val = value {
                return String(val)
            }
            
            fatalError("unresolved: \(id)")
        }

        init(id: String) {
            self.id = id
        }
        
        func evaluate() -> Int? {
            return value
        }
        
        func resolve(exprs: [String: Expression]) {
            guard value != nil else {
                fatalError("unresolved: \(id)")
            }
        }
        
        func reduce() -> Expression {
            return self
        }
    }
    
    class ConstExpression: Expression, CustomStringConvertible {
        init(id: String, value: Int) {
            super.init(id: id)
            self.value = value
        }
        
        var description: String {
            "\(id): \(value!)"
        }
    }
    
    class VariableExpression: Expression, CustomStringConvertible {
        var description: String {
            "\(id): x"
        }
        
        override var deepDescription: String {
            "x"
        }
        
        override func resolve(exprs: [String : day21.Expression]) {
        }
    }
    
    class ArithmeticExpression: Expression, CustomStringConvertible{
        let operands: (String, String)
        let operation: Character
        
        public private(set) var left: Expression?
        public private(set) var right: Expression?

        init(id: String, operands: (String, String), operation: Character) {
            self.operands = operands
            self.operation = operation
            super.init(id: id)
        }
        
        init(left: Expression, right: Expression, operation: Character) {
            self.operands = ("_", "_")
            self.operation = operation
            super.init(id: "_")
            self.left = left
            self.right = right
        }
        
        var description: String {
            "\(id): \(operands.0) \(operation) \(operands.1))"
        }
        
        override var deepDescription: String {
            guard resolved else {
                fatalError("unresolved: \(id)")
            }
            
            return "(\(left!.deepDescription) \(operation) \(right!.deepDescription))"
        }
        
        override var resolved: Bool {
            left != nil && right != nil
        }
        
        override func evaluate() -> Int? {
           if let val = value {
               return val
           }
           
           guard resolved else {
               fatalError("unresolved: \(id)")
           }
            
            if let a = left!.evaluate(), let b = right!.evaluate() {
                switch operation {
                case "+":
                    value = a+b
                    break
                case "-":
                    value = a-b
                    break
                case "*":
                    value = a*b
                    break
                case "/":
                    value = a/b
                    break
                default:
                    fatalError("operation unknown: \(operation)")
                }
                
                return value!
            }

            return nil
        }
        
        func invert(other: ConstExpression) -> (ConstExpression, Expression) {
            var inverseOperation: Character
            
            switch operation {
            case "+":
                inverseOperation = "-"
                break
            case "-":
                inverseOperation = "+"
                break
            case "*":
                inverseOperation = "/"
                break
            case "/":
                inverseOperation = "*"
                break
            default:
                fatalError("operation unknown: \(operation)")
            }
            
            if operation == "/" && left is ConstExpression {
                fatalError()
            }
            
            if let operand = left as? ConstExpression {
                if operation == "-" {
                    let nextExpr = ArithmeticExpression(left: other, right: right!, operation: inverseOperation).reduce()
                    return (operand, nextExpr)
                }
                
                let nextConst = ArithmeticExpression(left: other, right: operand, operation: inverseOperation).reduce()
                return (nextConst as! ConstExpression, right!)
            }
            
            if let operand = right as? ConstExpression {
                let nextConst = ArithmeticExpression(left: other, right: operand, operation: inverseOperation).reduce()
                return (nextConst as! ConstExpression, left!)
            }
            
            fatalError("left or right must be const")
        }
        
        override func resolve(exprs: [String: Expression]) {
            guard !resolved else {
                return
            }
            
            left = exprs[operands.0]
            right = exprs[operands.1]
            
            left!.resolve(exprs: exprs)
            right!.resolve(exprs: exprs)
        }
        
        override func reduce() -> day21.Expression {
            left = left!.reduce()
            right = right!.reduce()
            
            if let const = evaluate() {
                return ConstExpression(id: id, value: const)
            }
            
            return self
        }
    }
}
