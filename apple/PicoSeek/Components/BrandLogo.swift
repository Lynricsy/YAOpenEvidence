import SwiftUI

/// 图片集自动选择浅深外观，保留原始品牌配色。
struct BrandLogo: View {
    var size: CGFloat
    /// 与品牌文字并排时保持 nil，避免重复朗读。
    var label: String?

    init(size: CGFloat, label: String? = nil) {
        self.size = size
        self.label = label
    }

    var body: some View {
        let logo = Image("BrandLogo")
            .renderingMode(.original)
            .interpolation(.high)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)

        if let label {
            logo.accessibilityLabel(label)
        } else {
            logo.accessibilityHidden(true)
        }
    }
}
