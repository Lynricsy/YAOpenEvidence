import Testing
@testable import PicoSeekKit

@Test func apiVersionIsV1() {
    #expect(PicoSeekKit.apiVersion == "v1")
}
