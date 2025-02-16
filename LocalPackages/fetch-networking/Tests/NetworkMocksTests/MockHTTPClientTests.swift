import Testing
import NetworkMocks
import CoreNetworking
import Foundation

// Note to reviewer: Since `MockHTTPClient` is used in lots of the tests I decided
// to write tests around it to make sure I'm not relying on a faulty mock
struct Test {
    @Test func testCallBacksThrowIfNil() async throws {
        let sut = MockHTTPClient<String>()
        await #expect(
            throws: MockHTTPClient<String>.Errors.sendTCallbackNil,
            performing: {
                try await sut.send<String>(request: HTTPRequest<String>.get(""))
            }
        )

        await #expect(
            throws: MockHTTPClient<String>.Errors.sendDataCallbackNil,
            performing: {
                try await sut.send<Data>(request: HTTPRequest<Data>.get(""))
            }
        )
    }

    @Test func testRequestMismatch() async throws {
        let sut = MockHTTPClient<String>()
        await #expect(
            throws: MockHTTPClient<String>.Errors.typeTandUMismatch,
            performing: {
                try await sut.send<Int>(request: HTTPRequest<Int>.get(""))
            }
        )
    }

    @Test func testSendData() async throws {
        let string = "String"
        let expectedData = string.data(using: .utf8)!
        let sut = MockHTTPClient<String>(sendDataCallback: { _ in
            return HTTPResponse(
                value: expectedData,
                data: expectedData,
                response: .init()
            )
        })
        #expect(try await sut.send<Data>(request: HTTPRequest<Data>.get("")).value == expectedData)
        #expect(try await sut.send<Data>(request: HTTPRequest<Data>.get("")).data == expectedData)
    }

    @Test func testSendString() async throws {
        let string = "String"
        let expectedData = string.data(using: .utf8)!
        let sut = MockHTTPClient<String>(sendCallback: { _ in
            return HTTPResponse(
                value: string,
                data: expectedData,
                response: .init()
            )
        })
        #expect(try await sut.send(request: HTTPRequest<String>.get("")).value == string)
        #expect(try await sut.send(request: HTTPRequest<String>.get("")).data == expectedData)
    }
}
