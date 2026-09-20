import Foundation

/// 一次滚动采样。把 `ScrollGeometry` 压成两个数，判定逻辑就不必认识 SwiftUI。
struct ScrollSample: Equatable {
    /// 顶部为 0 的纵向偏移，向下滚动递增。橡皮筋拉拽时会越出 `0 ... limit`。
    var offset: CGFloat
    /// 偏移的有效上界，即内容底部贴齐容器底部时的偏移。内容不满一屏时为负数。
    var limit: CGFloat
}

/// 底部提问框收放的滚动判定。仿 Safari 地址栏：向下滚动收起，向上滚动或回到顶部展开。
///
/// 刻意不依赖 SwiftUI：夹取上下界与两个阈值是这段逻辑唯一容易出错的地方，独立成值类型才能
/// 脱离界面直接验证。视图只负责把 `ScrollGeometry` 压成 `ScrollSample` 喂进来，再读 `scrolledDown`。
struct ComposerCollapse: Equatable {
    /// 顶部容差：这段距离内一律视作仍在顶部——刚进页面时提问框就该是完整可用的。
    static let topTolerance: CGFloat = 12
    /// 方向阈值：滤掉手指微抖造成的来回切换。
    static let directionTolerance: CGFloat = 6

    /// 当前是否「向下滚动且已离开顶部」，即提问框应收到最小形态。
    private(set) var scrolledDown = false

    /// 上一次被采纳的偏移。只有跨过方向阈值才更新，否则慢速滚动会被反复重置成噪音。
    private var lastOffset: CGFloat = 0

    /// 喂入一次滚动采样。
    ///
    /// 先把偏移夹进 `0 ... limit` 再判方向：橡皮筋越界与随后的回弹是同一个手势的两截，
    /// 不夹的话「拉到底再松手」会被读成一次向上滚动，用户还在往下看，提问框却自己放大了。
    mutating func track(_ sample: ScrollSample) {
        let limit = max(0, sample.limit)
        let offset = min(max(sample.offset, 0), limit)

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
