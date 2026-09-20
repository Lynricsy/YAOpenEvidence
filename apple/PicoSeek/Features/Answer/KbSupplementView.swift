import SwiftUI
import PicoSeekKit

/// 知识库补充：本次作答附带的知识库条目。「查看原文」切到文献库 Tab 并推入详情。
struct KbSupplementView: View {
    let hits: [KbHit]

    @Environment(AppModel.self) private var app

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeading(module: .kb, count: "\(hits.count) 条")
            VStack(spacing: 10) {
                ForEach(Array(hits.enumerated()), id: \.offset) { _, hit in
                    KbHitCard(hit: hit) { route in
                        app.libraryPath = [route]
                        app.selection = .library
                    }
                }
            }
        }
    }
}
