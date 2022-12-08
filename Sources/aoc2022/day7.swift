import Foundation

public class day7: Puzzle {
    public private(set) var input: [Substring]
    var machine = Machine()
    
    public init(input: [Substring]) {
        self.input = input
    }
    
    public convenience init() {
        self.init(input: day7.load())
    }
    
    public func solve() -> String {
        repl()
        
        return """
Part 1: \(part1())
Part 2: \(part2())
"""
    }
    
    public func part1() -> Int {
        var total = 0
        
        machine.visitDirectories{ (dir) in
            let size = dir.recursiveSize()
            if size <= 100000 {
                total += size
            }
        }
        
        return total
    }
    
    public func part2() -> Int {
        let total = 70000000
        let requiredFree = 30000000
        let used = machine.rootDir.recursiveSize()
        let unused = total - used
        
        let amountToDelete = requiredFree - unused
        
        return part2DFS(threshold: amountToDelete)
    }
    
    func part2DFS(threshold: Int) -> Int {
        let ans = DFS()
        _ = ans.part2dfs(dir: machine.rootDir, threshold: threshold)
        return ans.best
    }

    
    class DFS {
        var best = 70000000
        func part2dfs(dir: Dir, threshold: Int) -> Int {
            var size = dir.size
            
            for child in dir.subDirs.values {
                let childSize = part2dfs(dir: child, threshold: threshold)
                size += childSize
            }
            
            if size >= threshold {
                best = min(best, size)
            }
            return size
        }
    }
    
    public func repl() {
        let commands = parse()

        for (command, output) in commands {
            machine.execute(command: command, output: output)
        }
    }
    
    func parse() -> [(cmd: Command, output: [Substring])] {
        var items = [(cmd: Command, output: [Substring])]()
        var line = input.startIndex
        
        while line < input.endIndex {
            let cmd = input[line]
            let outputStart = input.index(line, offsetBy: 1)
            var outputEnd = outputStart
            while outputEnd < input.endIndex && !input[outputEnd].starts(with: "$") {
                outputEnd = input.index(outputEnd, offsetBy: 1)
            }
            let out = input[outputStart..<outputEnd]
            items.append( (cmd: day7.parseCommand(cmd), output: Array(out)) )
            line = outputEnd
        }
        
        return items
    }
    
    static func parseCommand(_ line: Substring) -> Command {
        let parts = line.components(separatedBy: " ")
        if parts[1] == "cd" {
            switch parts[2] {
            case "/":
                return ChangeDirToRoot()
            case "..":
                return AscendDir()
            default:
                return DescendDir(subDir: parts[2])
            }
        }
        
        if parts[1] == "ls" {
            return ListCommand()
        }
        return UnsupportedCommand()
    }
    
    public static func load(resourceName: String = "day7") -> [Substring] {
        Resources.loadLines(resoureName: resourceName)
    }
}

protocol Command {
    func execute(machine: Machine, output: [Substring])
}

class Machine {
    let rootDir = Dir(name: "")
    private(set) var dirStack = [Dir]()
    
    var currentDir: Dir? {
        dirStack.last
    }
    
    var pwd: String {
        dirStack
            .map{$0.name + "/"}
            .reduce("", +)
    }
    
    func execute(command: Command, output: [Substring]) {
        command.execute(machine: self, output: output)
    }
    
    func changeToRootDir() {
        dirStack = [rootDir]
    }
    
    func descend(_ name: String) {
        dirStack.append(currentDir!.subDirs[name]!)
    }
    
    func ascend() {
        dirStack.removeLast()
    }
    
    func addSubDir(_ name: String) {
        currentDir!.subDirs[name] = Dir(name: name)
    }
    
    func addFile(name: String, size: Int) {
        currentDir!.files.insert(File(name: name, size: size))
    }
    
    func visitDirectories(_ tfm: (Dir) -> Void) {
        visitDirectories(tfm, dir: dirStack.first!)
    }
    
    private func visitDirectories(_ tfm: (Dir) -> Void, dir: Dir) {
        tfm(dir)
        for child in dir.subDirs.values {
            visitDirectories(tfm, dir: child)
        }
    }
}

class ChangeDirToRoot: Command {
    func execute(machine: Machine, output: [Substring]) {
        machine.changeToRootDir()
    }
}

class DescendDir: Command {
    let subDir: String

    init(subDir: String) {
        self.subDir = subDir
    }

    func execute(machine: Machine, output: [Substring]) {
        machine.descend(subDir)
    }
}

class AscendDir: Command {
    func execute(machine: Machine, output: [Substring]) {
        machine.ascend()
    }
}

class ListCommand: Command {
    func execute(machine: Machine, output: [Substring]) {
        for line in output {
            let parts = line.components(separatedBy: " ")
            let data = parts[0]
            let name = parts[1]
            if data == "dir" {
                machine.addSubDir(name)
            } else {
                machine.addFile(name: name, size: Int(data)!)
            }
        }
    }
}

class UnsupportedCommand: Command {
    func execute(machine: Machine, output: [Substring]) {
        assert(false, "Unsupported command")
    }
    
}

class Dir: Hashable, Equatable {
    let name: String
    var files = Set<File>()
    var subDirs = [String: Dir]()
    
    init(name: String) {
        self.name = name
    }
    
    var size: Int {
        files.map(\.size).reduce(0, +)
    }
    
    func recursiveSize() -> Int {
        return size
            + subDirs.values.map{ $0.recursiveSize() }.reduce(0, +)
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
    
    static func == (lhs: Dir, rhs: Dir) -> Bool {
        lhs.name == rhs.name
    }
}

struct File: Hashable {
    let name: String
    let size: Int
    
    init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}
