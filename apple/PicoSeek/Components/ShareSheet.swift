#if os(iOS)
    import SwiftUI
    import UIKit

    /// 系统分享面板。iOS 没有保存面板，「存储到文件」是分享面板里的一项。
    struct ShareSheet: UIViewControllerRepresentable {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }

        func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
    }
#endif
