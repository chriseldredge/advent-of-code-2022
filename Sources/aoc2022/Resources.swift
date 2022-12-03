import Foundation

public struct Resources {
    public static func loadLines(resoureName: String) -> Array<Substring> {
        return loadInput(resoureName: resoureName).split(
            omittingEmptySubsequences: false,
            whereSeparator: \.isNewline)
    }
    
    static func loadInput(resoureName: String) -> String {
        let path = Bundle.module.url(forResource: resoureName, withExtension: "txt")
        do {
            return try String(contentsOf: path!, encoding: .utf8)
        } catch {
            return "\(error)"
        }
    }
}

