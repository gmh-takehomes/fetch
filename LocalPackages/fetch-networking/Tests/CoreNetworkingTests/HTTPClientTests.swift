import Testing
import CoreNetworking
import Foundation
import NetworkMocks

// Must be serialized due to the use of `URLProtocolMock`
@Suite(.serialized) struct HTTPClientTests {
    struct CodableType: Codable, Equatable {
        let id: String
    }

    let sut: HTTPClient

    init() {
        let configure = URLSessionConfiguration.ephemeral
        configure.protocolClasses = [URLProtocolMock.self]

        sut = HTTPClient(
            host: "",
            configure: configure
        )
    }

    @Test func sendDecodable() async throws {
        let expectedModel = CodableType(id: "test")
        let responseData = try JSONEncoder().encode(expectedModel)

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }

        let model: HTTPResponse<CodableType> = try await sut.send(request: .get("test"))
        #expect(model.value == expectedModel)
    }
    
    @Test func sendData() async throws {
        let expectedData = "mock".data(using: .utf8)!

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, expectedData)
        }

        let model: HTTPResponse<Data> = try await sut.send(request: .get("test"))
        #expect(model.data == expectedData)
    }
}
/// inspired by: https://www.swiftwithvincent.com/blog/how-to-mock-any-network-call-with-urlprotocol
/// 
/// Extremely not type safe do not use other places
/// See ``MockHTTPClient``
private final class URLProtocolMock: URLProtocol {
    public typealias MockRequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data)

    public nonisolated(unsafe) static var requestHandler: MockRequestHandler?

    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        guard let handler = Self.requestHandler else { return }

        self.perform(request, handler: handler)
    }

    public override func stopLoading() {}


    private func perform(_ request: URLRequest, handler: MockRequestHandler) {
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowedInMemoryOnly)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
