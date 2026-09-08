import SwiftUI

/// 全局布局常量。散落的魔法数集中到这里，保证页面之间的留白与圆角一致。
enum Metrics {
    /// 页面水平内边距。
    static let pageInset: CGFloat = 16
    /// 阅读列最大宽度：超宽屏（iPad / Mac）上限制行长。
    static let contentMaxWidth: CGFloat = 720
    /// 内容卡片圆角。
    static let cardRadius: CGFloat = 16
    /// 输入框容器圆角。
    static let composerRadius: CGFloat = 26
    /// 同一页面内区块之间的间距。
    static let sectionSpacing: CGFloat = 20
}

extension Color {
    /// 内容卡片填充色：iOS 用 `secondarySystemBackground`，macOS 用 `controlBackgroundColor`。
    /// 内容层刻意不用玻璃材质——玻璃属于导航与控件层。
    static var cardFill: Color {
        #if os(iOS)
            Color(.secondarySystemBackground)
        #else
            Color(nsColor: .controlBackgroundColor)
        #endif
    }
}

extension View {
    /// 内容卡片：统一的内边距、左对齐与圆角填充。
    func card(padding: CGFloat = 14) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardFill, in: .rect(cornerRadius: Metrics.cardRadius))
    }

    /// 悬浮输入框容器：贴在安全区底部（键盘弹出时自动上移）。
    func floatingComposer<V: View>(@ViewBuilder _ content: () -> V) -> some View {
        safeAreaInset(edge: .bottom) {
            content()
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }

    /// 圆角输入框：登录页与表单外的自由文本输入，替代系统 `.roundedBorder`。
    func roundedField() -> some View {
        modifier(RoundedField())
    }

    /// 引文块左侧竖条。
    func quoteBar() -> some View {
        self
            .padding(.leading, 10)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(.tertiary)
                    .frame(width: 3)
            }
    }
}

/// 可按压卡片按钮样式：按下时轻微缩放与降透明度，给出触觉之外的视觉反馈。
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableCardStyle {
    static var pressableCard: Self { PressableCardStyle() }
}

/// 圆角输入框修饰器。
struct RoundedField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.cardFill, in: .rect(cornerRadius: 12))
    }
}
