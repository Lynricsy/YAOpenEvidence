import Foundation

/// 智能体工具调用的展示规则。与 `frontend/src/lib/tools.ts` 逐字一致：
/// 同一次调用无论在哪一端看，中文动作、参数摘要与耗时都是同一份文案。
public enum ToolPresentation {
    /// MCP 工具名 → 中文动作与 SF Symbol。
    private static let tools: [String: (label: String, symbol: String)] = [
        "search_papers": ("检索 Semantic Scholar", "magnifyingglass"),
        "pubmed_search": ("检索 PubMed", "magnifyingglass"),
        "get_paper": ("查看论文详情", "doc.text"),
        "pubmed_fetch": ("获取 PubMed 记录", "doc.text"),
        "get_citations": ("查看引用文献", "quote.opening"),
        "get_references": ("查看参考文献", "book"),
        "get_recommendations": ("查找相似论文", "sparkles"),
        "search_authors": ("检索作者", "person"),
        "get_fulltext": ("读取全文（PMC）", "doc.plaintext"),
        "read_pdf": ("读取 PDF", "doc.richtext"),
        "kb_search": ("查询知识库", "internaldrive"),
        "exec": ("执行命令", "terminal"),
    ]

    /// 未登记的工具退回 `server/tool` 原文：宁可难看，也不要把它藏起来。
    public static func label(server: String, tool: String) -> String {
        tools[tool]?.label ?? "\(server)/\(tool)"
    }

    public static func symbol(tool: String) -> String {
        tools[tool]?.symbol ?? "wrench"
    }

    /// 参数里最能说明「在查什么」的那一个键；顺序即优先级。
    private static let argKeys = ["query", "name", "paper_id", "pmids", "path", "command"]

    /// 一行式参数摘要，例如「读取 PDF」后面的「「x.pdf」 · results」。
    public static func describeArgs(_ args: JSONValue) -> String {
        guard let key = argKeys.first(where: { args[$0] != nil }),
              let raw = args[key].map(text) else { return "" }
        let clipped = raw.count > 60 ? String(raw.prefix(60)) + "…" : raw
        let section = args["section"]?.stringValue ?? ""
        return "「\(clipped)」" + (section.isEmpty ? "" : " · \(section)")
    }

    /// 毫秒 → `0.8s`；未知耗时给空串，别在轨迹上写一个假的 0。
    public static func formatDuration(_ ms: Int?) -> String {
        guard let ms else { return "" }
        return String(format: "%.1fs", Double(ms) / 1000)
    }

    /// 标量值转字符串：整数不带小数点（后端 JSON 里整数也会解成 Double）。
    private static func text(_ value: JSONValue) -> String {
        switch value {
        case .string(let v): v
        case .number(let v): v == v.rounded() ? String(Int(v)) : String(v)
        case .bool(let v): v ? "true" : "false"
        default: ""
        }
    }
}
