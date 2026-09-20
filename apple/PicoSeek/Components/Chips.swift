import SwiftUI

/// 可选中的胶囊选项：分区、文献类型、章节等多选/单选场景共用。
struct ChoiceChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(selected ? Color.accentColor : Color.cardFill, in: .capsule)
                .foregroundStyle(selected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.15), value: selected)
        .sensoryFeedback(.selection, trigger: selected)
    }
}
