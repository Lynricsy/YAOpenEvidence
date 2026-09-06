import Testing
@testable import YAOEKit

@Suite("SSEParser")
struct SSEParserTests {
    /// 把完整的 SSE 报文按行喂进解析器。
    private func events(from stream: String) -> [SSEEvent] {
        var parser = SSEParser()
        var out: [SSEEvent] = []
        for line in stream.components(separatedBy: "\n") {
            if let event = parser.feed(line: line) { out.append(event) }
        }
        return out
    }

    @Test("心跳注释不产出事件")
    func heartbeatIgnored() {
        let stream = ": ping\n\nid: 1-0\nevent: stage\ndata: {\"stage\":\"search\",\"status\":\"started\"}\n\n"
        let parsed = events(from: stream)
        #expect(parsed.count == 1)
        #expect(parsed[0].id == "1-0")
        #expect(parsed[0].event == "stage")
        #expect(parsed[0].data == #"{"stage":"search","status":"started"}"#)
    }

    @Test("缺省事件名为 message，多行 data 用换行连接")
    func defaultsAndMultilineData() {
        let parsed = events(from: "data: a\ndata: b\n\n")
        #expect(parsed.count == 1)
        #expect(parsed[0].event == "message")
        #expect(parsed[0].id == nil)
        #expect(parsed[0].data == "a\nb")
    }

    @Test("事件之间状态不残留")
    func stateResetsBetweenEvents() {
        let parsed = events(from: "id: 5-0\nevent: log\ndata: {}\n\nevent: cancelled\ndata: {}\n\n")
        #expect(parsed.count == 2)
        #expect(parsed[0].id == "5-0")
        #expect(parsed[1].id == nil)
        #expect(parsed[1].event == "cancelled")
    }

    @Test("CRLF 行尾与无 data 的帧")
    func crlfAndEmptyFrames() {
        let parsed = events(from: "event: ping\r\n\r\nid: 9-1\r\ndata: x\r\n\r\n")
        #expect(parsed.count == 1)
        #expect(parsed[0].id == "9-1")
        #expect(parsed[0].data == "x")
    }
}
