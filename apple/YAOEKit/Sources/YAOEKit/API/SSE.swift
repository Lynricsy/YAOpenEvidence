import Foundation

/// 一帧 Server-Sent Event。
public struct SSEEvent: Sendable, Hashable {
    public var id: String?
    public var event: String
    public var data: String

    public init(id: String? = nil, event: String = "message", data: String) {
        self.id = id
        self.event = event
        self.data = data
    }
}

/// 逐行喂入的 SSE 解析器：空行触发派发，`:` 开头是注释（心跳）。
public struct SSEParser: Sendable {
    private var id: String?
    private var event: String?
    private var dataLines: [String] = []

    public init() {}

    /// 喂入一行（不含换行符）；凑齐一帧时返回事件。
    public mutating func feed(line rawLine: String) -> SSEEvent? {
        // URLSession 按 \n 切行，CRLF 流会留下尾部 \r。
        let line = rawLine.hasSuffix("\r") ? String(rawLine.dropLast()) : rawLine
        if line.isEmpty { return dispatch() }
        if line.hasPrefix(":") { return nil }

        let field: String
        var value: String
        if let colon = line.firstIndex(of: ":") {
            field = String(line[line.startIndex ..< colon])
            value = String(line[line.index(after: colon)...])
            if value.hasPrefix(" ") { value.removeFirst() }
        } else {
            field = line
            value = ""
        }

        switch field {
        case "id": id = value
        case "event": event = value
        case "data": dataLines.append(value)
        default: break // retry 及未知字段忽略
        }
        return nil
    }

    private mutating func dispatch() -> SSEEvent? {
        defer {
            id = nil
            event = nil
            dataLines = []
        }
        guard !dataLines.isEmpty else { return nil }
        return SSEEvent(id: id, event: event ?? "message", data: dataLines.joined(separator: "\n"))
    }
}
