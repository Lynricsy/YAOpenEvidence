import Testing
@testable import PicoSeekKit

@Suite("AskRail")
struct AskRailTests {
    private func kbNode(_ kb: BackgroundKb?, settled: Bool = true) -> RailNode {
        let nodes = askRailNodes(live: .empty, useKb: true, kb: kb, settled: settled)
        return nodes[nodes.count - 1]
    }

    @Test("写库排在综合成稿之后，答案出来前保持未开始")
    func order() {
        let nodes = askRailNodes(live: .empty, useKb: true)
        #expect(nodes.map(\.key) == ["queries", "search", "fulltext", "read", "synthesize", "kb"])
        #expect(nodes.map(\.label).last == "写入知识库")
        #expect(nodes.allSatisfy { $0.status == .todo })
        #expect(kbNode(nil, settled: false).hint == "答案交付后在后台进行")
    }

    @Test("关掉写库时不出现该节点")
    func withoutKb() {
        let nodes = askRailNodes(live: .empty, useKb: false, kb: BackgroundKb(status: .running, current: 1, total: 3))
        #expect(!nodes.contains { $0.key == "kb" })
        #expect(nodes.count == 5)
    }

    @Test("答案已出：前序阶段一律完成，实时状态为空也不全灰")
    func settledStagesDone() {
        let nodes = askRailNodes(live: .empty, useKb: true, kb: nil, settled: true)
        #expect(nodes.prefix(5).allSatisfy { $0.status == .done })
    }

    @Test("运行中的阶段按实时状态区分进行中与已完成")
    func liveStages() {
        var live = JobLive.empty
        live = live.applying(SSEEvent(id: nil, event: "stage", data: #"{"stage":"search","status":"finished"}"#))
        live = live.applying(SSEEvent(id: nil, event: "stage", data: #"{"stage":"read","status":"started"}"#))
        let nodes = askRailNodes(live: live, useKb: true)
        #expect(nodes[1].status == .done)
        #expect(nodes[3].status == .running)
        #expect(nodes[4].status == .todo)
    }

    @Test("后台任务的状态与副文案逐字对应")
    func kbStates() {
        #expect(kbNode(BackgroundKb(status: .queued, current: 0, total: 10)).status == .waiting)
        #expect(kbNode(BackgroundKb(status: .queued, current: 0, total: 10)).hint == "等待后台，优先执行新问答（0/10 篇）")
        #expect(kbNode(BackgroundKb(status: .running, current: 3, total: 10)).status == .running)
        #expect(kbNode(BackgroundKb(status: .running, current: 3, total: 10)).hint == "后台写入中（3/10 篇）")
        #expect(kbNode(BackgroundKb(status: .succeeded, current: 10, total: 10)).status == .done)
        #expect(kbNode(BackgroundKb(status: .succeeded, current: 10, total: 10)).hint == "已写入 10 篇")
        #expect(kbNode(BackgroundKb(status: .failed, current: 4, total: 10)).status == .failed)
        #expect(kbNode(BackgroundKb(status: .failed, current: 4, total: 10)).hint == "写入失败，答案不受影响")
        #expect(kbNode(BackgroundKb(status: .cancelled, current: 1, total: 10)).status == .cancelled)
        #expect(kbNode(BackgroundKb(status: .cancelled, current: 1, total: 10)).hint == "已取消，答案不受影响")
        #expect(kbNode(BackgroundKb(status: .unknown)).status == .todo)
        #expect(kbNode(BackgroundKb(status: .unknown)).hint == "状态暂时无法读取")
    }

    @Test("总数未知时不拼计数")
    func withoutCount() {
        #expect(kbNode(BackgroundKb(status: .running)).hint == "后台写入中")
        #expect(kbNode(BackgroundKb(status: .succeeded)).hint == "已写入")
        #expect(kbNode(BackgroundKb(status: .queued)).hint == "等待后台，优先执行新问答")
    }
}
