import SwiftUI
import YAOEKit

extension Color {
    /// `#rrggbb` → Color；解析失败回落为灰色（只用于常量色板，不会在运行期变化）。
    init(hex: String) {
        let text = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard text.count == 6, let value = UInt32(text, radix: 16) else {
            self = .gray
            return
        }
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    /// 深色模式下把品牌引用色提亮，保证与深色背景的对比度。
    func lightenedForDark(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? mix(with: .white, by: 0.25) : self
    }
}

enum CitationPalette {
    /// 第 n 篇文献的引用色（已按外观模式调整）。
    static func color(_ n: Int, _ scheme: ColorScheme) -> Color {
        Color(hex: Citations.colorHex(n: n)).lightenedForDark(scheme)
    }
}
