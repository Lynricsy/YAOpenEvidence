import Foundation
import Testing
@testable import YAOEKit

@Suite("Content-Disposition")
struct ContentDispositionTests {
    /// 服务端同时给两个参数：ASCII 的 `filename` 只为老客户端兜底，中文名在 `filename*` 里。
    /// 取错分支用户拿到的就是 `YAOpenEvidence-<id>.pdf` 这种无意义文件名。
    @Test("同时存在时取 RFC 5987 的 filename* 并百分号解码")
    func prefersExtendedFilename() {
        let header = """
        attachment; filename="YAOpenEvidence-a1b2.pdf"; \
        filename*=UTF-8''YAOpenEvidence-20260919-%E4%B9%B3%E8%85%BA%E7%99%8C%E7%9A%84%E9%9D%B6%E5%90%91%E6%B2%BB%E7%96%97.pdf
        """
        #expect(APIClient.filename(fromContentDisposition: header) == "YAOpenEvidence-20260919-乳腺癌的靶向治疗.pdf")
    }

    @Test("只有 filename 时取引号里的原样文件名")
    func fallsBackToQuotedFilename() {
        #expect(APIClient.filename(fromContentDisposition: "attachment; filename=\"a.pdf\"") == "a.pdf")
    }

    @Test("没有响应头时返回 nil，由调用方兜底命名")
    func returnsNilWithoutHeader() {
        #expect(APIClient.filename(fromContentDisposition: nil) == nil)
    }
}
