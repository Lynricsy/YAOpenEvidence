import SwiftUI
import UniformTypeIdentifiers

/// `fileExporter` 的载体：PDF 已是服务端渲染好的字节，这里不做任何解析或重排。
struct PDFFileDocument: FileDocument {
    static let readableContentTypes = [UTType.pdf]

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
