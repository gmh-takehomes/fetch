import Foundation

// Note to reviewer: This could be expanded to include other types of requests
public struct HTTPRequest<T: Sendable>: Sendable {
    public var method: RequestMethod
    public var path: String

    // Set to `reloadIgnoringLocalAndRemoteCacheData` to show custom caching implmentation
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData


    public static func get(
        _ path: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        .init(method: .get, path: path)
    }
}


