import Testing
@testable import PicoSeekKit

@Suite("AnswerSections")
struct AnswerSectionsTests {
    @Test("V1 破折号同行标签")
    func dashInline() {
        let markdown = """
        **结论 / Bottom line** — 依据现有证据给出简要结论 [1¶2]。

        **证据 / Evidence**
        - 队列研究报告了主要结局 [1¶2]。

        **PICOS 证据表 / PICOS table**

        | [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |
        |---|---|---|---|---|---|
        | [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |

        **局限 / Caveats**
        - 观察性设计，存在残余混杂。
        """
        let sections = AnswerSections.split(markdown)
        #expect(sections.map(\.kind) == [.conclusion, .evidence, .picos, .caveats])
        #expect(sections[0].markdown == "依据现有证据给出简要结论 [1¶2]。")
        #expect(sections[1].markdown == "- 队列研究报告了主要结局 [1¶2]。")
        #expect(sections[2].markdown == """
        | [n] | P 研究对象 | I 干预措施 | C 对照方式 | O 结局指标 | S 研究设计 |
        |---|---|---|---|---|---|
        | [1] | 成人 | 干预 | 对照 | 主要结局 | 队列研究 |
        """)
        #expect(sections[3].markdown == "- 观察性设计，存在残余混杂。")
        #expect(AnswerSections.hasKnownSections(sections))
    }

    @Test("V2 冒号标签、缺 PICOS、子弹内粗体不算分节头")
    func colonLabels() {
        let markdown = "**结论 / Bottom line**:\n阿司匹林可降低事件风险。\n\n"
            + "**证据 / Evidence**:  \n- **糖尿病患者**：HR 0.88 [1]。\n\n"
            + "**局限 / Caveats**:\n- 人群异质性大。"
        let sections = AnswerSections.split(markdown)
        #expect(sections.map(\.kind) == [.conclusion, .evidence, .caveats])
        #expect(sections[0].markdown == "阿司匹林可降低事件风险。")
        #expect(sections[1].markdown == "- **糖尿病患者**：HR 0.88 [1]。")
        #expect(sections[2].markdown == "- 人群异质性大。")
    }

    @Test("V3 标题形式与英文标签")
    func headingLabels() {
        let sections = AnswerSections.split("## 结论\nA\n\n### Evidence\n- b")
        #expect(sections.map(\.kind) == [.conclusion, .evidence])
        #expect(sections[0].markdown == "A")
        #expect(sections[1].markdown == "- b")
    }

    @Test("V4 无标签整段回退")
    func noLabels() {
        let sections = AnswerSections.split("# Q: 问题\n\n正文 [1]")
        #expect(sections.map(\.kind) == [.other])
        #expect(sections[0].markdown == "# Q: 问题\n\n正文 [1]")
        #expect(AnswerSections.hasKnownSections(sections) == false)
    }

    @Test("问题标题含「证据」不算分节头")
    func questionTitleIsNotSection() {
        let markdown = "# Q: SGLT2 抑制剂在 HFpEF 的证据强度\n\n正文 [1]"
        let sections = AnswerSections.split(markdown)
        #expect(sections.map(\.kind) == [.other])
        #expect(sections[0].markdown == markdown)
        #expect(AnswerSections.hasKnownSections(sections) == false)
    }

    @Test("V5 前言保留、同类模块合并")
    func mergeSameKind() {
        let sections = AnswerSections.split("前言\n\n**结论**\nA\n\n**证据**\n- x\n\n**证据**\n- y")
        #expect(sections.map(\.kind) == [.other, .conclusion, .evidence])
        #expect(sections[0].markdown == "前言")
        #expect(sections[1].markdown == "A")
        #expect(sections[2].markdown == "- x\n\n- y")
    }

    @Test("V6 非分节粗体行留在内容里")
    func unknownBoldStaysInline() {
        let sections = AnswerSections.split("**结论 / Bottom line**\nA\n\n**其他要点**\nB")
        #expect(sections.map(\.kind) == [.conclusion])
        #expect(sections[0].markdown == "A\n\n**其他要点**\nB")
    }

    @Test("V7 空输入")
    func emptyInput() {
        #expect(AnswerSections.split("").isEmpty)
        #expect(AnswerSections.split("  \n\n").isEmpty)
    }

    @Test("标签判定用前缀匹配，PICOS 先于证据")
    func kindOfLabel() {
        #expect(AnswerSections.kind(ofLabel: "PICOS 证据表 / PICOS table") == .picos)
        #expect(AnswerSections.kind(ofLabel: " 结论 / Bottom line ") == .conclusion)
        #expect(AnswerSections.kind(ofLabel: "Evidence") == .evidence)
        #expect(AnswerSections.kind(ofLabel: "Limitations") == .caveats)
        #expect(AnswerSections.kind(ofLabel: "其他要点") == nil)
        #expect(AnswerSections.kind(ofLabel: "Q: SGLT2 抑制剂在 HFpEF 的证据强度") == nil)
        #expect(AnswerSections.kind(ofLabel: "本节讨论 limitations") == nil)
    }
}
