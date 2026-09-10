import Foundation

/// 底部提问框收放的滚动判定。仿 Safari 地址栏：向下滚动收起，向上滚动或回到顶部展开。
///
/// 刻意不依赖 SwiftUI：阈值与顶部容差是这段逻辑唯一容易出错的地方，独立成值类型才能脱离
/// 界面直接验证。视图只负责把 `ScrollGeometry` 的偏移喂进来，再读 `scrolledDown`。
struct ComposerCollapse: Equatable {
    /// 顶部容差：这段距离内一律视作仍在顶部——刚进页面时提问框就该是完整可用的。
    static let topTolerance: CGFloat = 12
    /// 方向阈值：滤掉手指微抖与滚动回弹造成的来回切换。
    static let directionTolerance: CGFloat = 6

    /// 当前是否「向下滚动且已离开顶部」，即提问框应收到最小形态。
    private(set) var scrolledDown = false

    /// 上一次被采纳的偏移。只有跨过方向阈值才更新，否则慢速滚动会被反复重置成噪音。
    private var lastOffset: CGFloat = 0

    /// 喂入滚动偏移：`offset` 已加上顶部内边距，顶部为 0，向下滚动递增。
    mutating func track(offset: CGFloat) {
        guard offset > Self.topTolerance else {
            lastOffset = offset
            scrolledDown = false
            return
        }
        let delta = offset - lastOffset
        guard abs(delta) > Self.directionTolerance else { return }
        lastOffset = offset
        scrolledDown = delta > 0
    }
}
