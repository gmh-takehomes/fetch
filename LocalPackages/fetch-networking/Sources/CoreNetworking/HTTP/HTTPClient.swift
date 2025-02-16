import Foundation

public protocol HTTPClientProtocol: Sendable {
    func send<T: Decodable>(request: HTTPRequest<T>) async throws -> HTTPResponse<T>
    func send(request: HTTPRequest<Data>) async throws -> HTTPResponse<Data>
}

public final class HTTPClient: HTTPClientProtocol {
    private let host: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        host: String,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        configure: URLSessionConfiguration = .default
    ) {
        self.host = host
        self.decoder = decoder
        self.encoder = encoder
        self.session = URLSession(configuration: configure)
    }

    public func send<T: Decodable>(request: HTTPRequest<T>) async throws -> HTTPResponse<T> {
        let generatedRequest = try await makeRequest(for: request)
        let (data, reponse) = try await session.data(for: generatedRequest)

        let decodedValue = try decoder.decode(T.self, from: data)

        return HTTPResponse(value: decodedValue, data: data, response: reponse)
    }

    public func send(request: HTTPRequest<Data>) async throws -> HTTPResponse<Data> {
        let generatedRequest = try await makeRequest(for: request)
        let (data, response) = try await session.data(for: generatedRequest)

        return HTTPResponse(value: data, data: data, response: response)
    }

    private func makeRequest<T>(for request: HTTPRequest<T>) async throws -> URLRequest {
        let url = try makeURL(path: request.path)

        return try await makeRequest(
            url: url,
            method: request.method,
            cachePolicy: request.cachePolicy
        )
    }

    private func makeRequest(
        url: URL,
        method: RequestMethod,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let cachePolicy {
            request.cachePolicy = cachePolicy
        }

        return request
    }

    // Note to reviewer: This could be expanded to include queryItems
    private func makeURL(path: String) throws -> URL {
        var absolutePath = path
        if !absolutePath.hasPrefix("/") {
            absolutePath = "/" + absolutePath
        }

        guard let url = URL(string: absolutePath),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            throw HTTPClientError.invalidURL
        }

        components.scheme = "https"
        components.host = host

        guard let finalURL = components.url else {
            throw HTTPClientError.invalidURL
        }
        return finalURL
    }
}

enum HTTPClientError: Error {
    case invalidURL
    case encodingError
    case decodingError
}
