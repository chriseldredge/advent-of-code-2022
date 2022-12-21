import Foundation

public class day15: Puzzle {
    public private(set) var input = [Substring]()
    public private(set) var row = 0
    public private(set) var searchRange = 0...20
    
    public init() {
    }
    
    public func load(resourceName: String) {
        if resourceName.contains("sample") {
            row = 10
        } else {
            row = 2000000
            searchRange = 0...4000000
        }
        input = Resources.loadLines(resoureName: resourceName)
    }
    
    public func solvePart1() -> String {
        return "\(part1())"
    }
    
    public func solvePart2() -> String {
        return "\(part2())"
    }

    public func part1() -> Int {
        let sensors = day15.parse(input: input)

        let beaconIndices = Set(sensors
            .filter{ $0.nearestBeacon.y == row }
            .map { $0.nearestBeacon.x }
        )

        let ranges = day15.reduceRanges(
            sensors.compactMap{ $0.rangeFor(y: row) }
        )
        
        var delta = 0
        
        for x in beaconIndices {
            for r in ranges {
                if r.contains(x) {
                    delta += 1
                    break
                }
            }
        }

        return ranges.map(\.count).reduce(0, +) - delta
    }
    
    public func part2() -> Int {
        let sensors = day15.parse(input: input)

        for y in searchRange {
            let r = day15.reduceRanges(
                sensors
                    .compactMap{ $0.rangeFor(y: y) }
                    .map{ $0.clamped(to: searchRange) }
            )
            
            let excluded = r.map(\.count).reduce(0, +)
            
            if excluded < searchRange.count {
                var x: Int
                
                if r.first!.lowerBound == 0 {
                    x = r.first!.upperBound + 1
                } else {
                    x = r.first!.lowerBound - 1
                }
                
                print("y=\(y) r=\(r)")
                return x*4000000+y
            }
        }
        
        return -1
    }
    
    static func reduceRanges(_ ranges: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
        if ranges.count < 2 {
            return ranges
        }
        
        var result = [ClosedRange<Int>](ranges)
        var targetIndex = result.startIndex
        var didMerge = false

        while targetIndex < result.endIndex-1 {
            for otherIndex in stride(from: result.endIndex-1, to: targetIndex, by: -1) {
                let o = result[otherIndex]
                let r = result[targetIndex]
                if r.overlaps(o) || r.abuts(o) {
                    result[targetIndex] = min(r.lowerBound, o.lowerBound)...max(r.upperBound, o.upperBound)
                    result.remove(at: otherIndex)
                    didMerge = true
                }
            }
            targetIndex += 1
        }
        
        if (didMerge) {
            return reduceRanges(result)
        }
        
        return result
    }
    
    static func parse(input: [Substring]) -> [Sensor] {
        var list = [Sensor]()
        for line in input {
            let numbers = line
                .components(separatedBy: .whitespaces)
                .map{ $0.components(separatedBy: "=").last! }
                .map{ $0.trimmingCharacters(in: CharacterSet(charactersIn: ",:")) }
            
            list.append(Sensor(
                location: Point(x: Int(numbers[2])!, y: Int(numbers[3])!),
                nearestBeacon: Point(x: Int(numbers[8])!, y: Int(numbers[9])!)))
        }
        
        return list
    }

    class Sensor: CustomStringConvertible {
        let location: Point
        let nearestBeacon: Point
        
        init(location: Point, nearestBeacon: Point) {
            self.location = location
            self.nearestBeacon = nearestBeacon
        }
        
        func rangeFor(y: Int) -> ClosedRange<Int>? {
            let vdist = abs(location.y - y)
            
            if vdist > distance {
                return nil
            }
            
            let hdist = distance - vdist
                        
            let xs = location.x - hdist
            let xe = location.x + hdist

            return xs...xe
        }
        
        func excludes(_ p: Point) -> Bool {
            p != nearestBeacon && distanceTo(p) <= distance
        }
        
        func distanceTo(_ p: Point) -> Int {
            abs(location.x - p.x) + abs(location.y - p.y)
        }
        
        var distance: Int {
            distanceTo(nearestBeacon)
        }
        
        var description: String {
            "Sensor location=\(location) nearest-beacon=\(nearestBeacon) distance=\(distance)"
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

extension ClosedRange<Int> {
    func abuts(_ o: ClosedRange<Int>) -> Bool {
        self.upperBound + 1 == o.lowerBound || self.lowerBound - 1 == o.upperBound
    }
}
