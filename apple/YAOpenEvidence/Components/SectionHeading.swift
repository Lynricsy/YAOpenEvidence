import SwiftUI

/// 答案页六个模块的固定展示元数据（标题文字不取模型输出，三端逐字一致）。
enum AnswerModule {
    case conclusion
    case evidence
    case picos
    case caveats
    case sources
    case kb

    var title: String {
        switch self {
        case .conclusion: "结论"
        case .evidence: "证据"
        case .picos: "PICOS 证据表"
        case .caveats: "局限"
        case .sources: "参考文献"
        case .kb: "知识库补充"
        }
    }

    var eyebrow: String {
        switch self {
        case .conclusion: "BOTTOM LINE"
        case .evidence: "EVIDENCE"
        case .picos: "PICOS TABLE"
        case .caveats: "CAVEATS"
        case .sources: "REFERENCES"
        case .kb: "KNOWLEDGE BASE"
        }
    }

    var symbol: String {
        switch self {
        case .conclusion: "checkmark.seal"
        case .evidence: "flask"
        case .picos: "tablecells"
        case .caveats: "exclamationmark.triangle"
        case .sources: "books.vertical"
        case .kb: "tray.full"
        }
    }

    var tone: Color {
        switch self {
        case .conclusion, .evidence, .picos: .accentColor
        case .caveats: .orange
        case .sources, .kb: .secondary
        }
    }
}

/// 模块分节头：图标方块 + 中文标题 + 英文小字 + 右侧计数，`rule` 控制下方分隔线。
struct SectionHeading: View {
    let module: AnswerModule
    var count: String?
    var rule = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: module.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(module.tone)
                    .frame(width: 28, height: 28)
                    .background(module.tone.opacity(0.12), in: .rect(cornerRadius: 7))
                Text(module.title)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                Text(module.eyebrow)
                    .font(.caption2.weight(.medium))
                    .kerning(0.8)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                Spacer(minLength: 0)
                if let count {
                    Text(count)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            if rule { Divider() }
        }
        .accessibilityElement(children: .combine)
    }
}
