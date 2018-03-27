import Foundation

public func printTable<T1, T2>(_ symbol: String, rows: [T1], cols: [T2], op: (T1, T2) -> T1) {
    let head = (0 ..< cols.count).reduce("\(symbol)\t|") { (res, j) in
        "\(res)\t\(cols[j])"
    }
    let line = String(repeating: "-", count: 4 * (cols.count + 1) + 2)
    let body = (0 ..< rows.count).map { i in
        return (0 ..< cols.count).reduce("\(rows[i])\t|") { (res, j) in
            "\(res)\t\(op(rows[i], cols[j]))"
        }
    }
    let result = ([head, line] + body).joined(separator: "\n")
    print(result)
    print()
}

public extension AdditiveGroup {
    public static func printAddTable(values: [Self]) {
        printTable("+", rows: values, cols: values) { $0 + $1 }
    }
}

public extension AdditiveGroup where Self: FiniteSetType {
    public static func printAddTable() {
        printAddTable(values: allElements)
    }
}

public extension Monoid {
    public static func printMulTable(values: [Self]) {
        printTable("*", rows: values, cols: values) { $0 * $1 }
    }

    public static func printExpTable(values: [Self], upTo n: Int) {
        printTable("^", rows: values, cols: Array(0 ... n)) { $0 ** $1 }
    }
}

public extension Monoid where Self: FiniteSetType {
    public static func printMulTable() {
        printMulTable(values: allElements)
    }

    public static func printExpTable() {
        let all = allElements
        printExpTable(values: all, upTo: all.count - 1)
    }
}
