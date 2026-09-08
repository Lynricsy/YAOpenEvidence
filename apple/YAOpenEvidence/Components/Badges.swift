import SwiftUI
import YAOEKit

/// 通用胶囊标签。
struct Pill: View {
    let text: String
    var tone: Color = .secondary
    var systemImage: String?

    var body: some View {
        Label {
            Text(text)
        } icon: {
            if let systemImage { Image(systemName: systemImage) }
        }
        .labelStyle(.titleAndIcon)
        .font(.caption.weight(.medium))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tone.opacity(0.16), in: .capsule)
        .foregroundStyle(tone)
    }
}

/// 任务 / 答案状态徽标。
struct StatusBadge: View {
    let status: AnswerStatus

    init(_ status: AnswerStatus) {
        self.status = status
    }

    init(_ status: JobStatus) {
        self.status = switch status {
        case .queued: .queued
        case .running: .running
        case .succeeded: .ready
        case .failed: .failed
        case .cancelled: .cancelled
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if status == .running {
                ProgressView().controlSize(.mini)
            }
            Pill(text: Self.label(for: status), tone: Self.tone(for: status))
        }
    }

    static func label(for status: AnswerStatus) -> String {
        switch status {
        case .queued: "排队中"
        case .running: "进行中"
        case .ready: "已完成"
        case .failed: "失败"
        case .cancelled: "已取消"
        }
    }

    static func tone(for status: AnswerStatus) -> Color {
        switch status {
        case .queued: .secondary
        case .running: .blue
        case .ready: .green
        case .failed: .red
        case .cancelled: .orange
        }
    }

    /// 侧栏「最近问答」的状态图标。
    static func symbol(for status: AnswerStatus) -> String {
        switch status {
        case .queued: "clock"
        case .running: "arrow.triangle.2.circlepath"
        case .ready: "checkmark.circle"
        case .failed: "exclamationmark.triangle"
        case .cancelled: "xmark.circle"
        }
    }
}

/// 期刊分区徽标：`quartile` 形如 `1` / `Q1`，无分区时显示 `rankLabel` 或「未收录」。
struct RankBadge: View {
    let quartile: String
    var rankLabel: String = ""

    private var zone: Int? {
        let text = quartile.trimmingCharacters(in: .whitespaces).uppercased()
        let digits = text.hasPrefix("Q") ? String(text.dropFirst()) : text
        guard let value = Int(digits), (1 ... 4).contains(value) else { return nil }
        return value
    }

    var body: some View {
        if let zone {
            Pill(text: "Q\(zone)", tone: Self.tone(zone))
        } else {
            let text = rankLabel.trimmingCharacters(in: .whitespaces)
            Pill(text: text.isEmpty ? "未收录" : text, tone: .secondary)
        }
    }

    static func tone(_ zone: Int) -> Color {
        switch zone {
        case 1: .green
        case 2: .blue
        case 3: .orange
        default: .gray
        }
    }
}

/// 文献来源徽标（全文来自 PMC / PDF / 机构，或仅摘要）。
struct SourceBadge: View {
    let source: PaperSource

    var body: some View {
        Pill(text: source.label, tone: source == .abstract ? .secondary : .teal)
    }
}

/// 引文核实状态。
struct VerifiedPill: View {
    let verified: Bool

    var body: some View {
        Pill(text: verified ? "已核实" : "未核实", tone: verified ? .green : .orange)
    }
}

/// 引用编号方块：颜色取自 8 色引用色板。
struct CitationSquare: View {
    let n: Int
    var size: CGFloat = 24
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("\(n)")
            .font(.system(size: size * 0.5, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(CitationPalette.color(n, colorScheme), in: .rect(cornerRadius: size * 0.25))
            .accessibilityLabel("第 \(n) 篇文献")
    }
}
