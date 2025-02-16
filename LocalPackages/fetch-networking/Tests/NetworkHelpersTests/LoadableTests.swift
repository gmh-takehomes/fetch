import Testing
import NetworkHelpers

struct LoadableTests {
    @Test func testLoadableArray_empty() async throws {
        let sut: LoadableArray<Int> = await LoadableArray {
            return []
        }
        #expect(sut == .empty)
    }

    @Test func testLoadableArray_loaded() async throws {
        let sut: LoadableArray<Int> = await LoadableArray {
            return [1, 2]
        }
        #expect(sut == .loaded([1, 2]))
    }


    @Test func testLoadableArray_failed() async throws {
        let sut: LoadableArray<Int> = await LoadableArray {
            throw MockError.didNotLoad
        }
        #expect(sut == .failed)
    }

    enum MockError: Error {
        case didNotLoad
    }
}
