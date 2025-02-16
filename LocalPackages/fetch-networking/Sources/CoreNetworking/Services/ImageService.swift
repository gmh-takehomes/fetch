import SwiftUI

typealias ImageMemoryCache = GenericCache<String, CodableUIImage>
typealias ImageRemoteRepository = RemoteRepository<String, CodableUIImage>

/// A service responsible for fetching images.
public protocol ImageServicing: Sendable {
    /// Fetches an image from the given path.
    ///
    /// - Parameter path: A `String` representing the absolute path of the image.
    /// - Returns: The corresponding `Image`.
    nonisolated func fetchImage(_ path: String) async throws -> Image

    /// Clears any cached images stored by the service.
    func emptyCache() async
}

/// A general  service for fetching images  that abstracts caching and remote fetching details.
///
/// This service provides an reusable interface for retrieving images while internally managing
/// caching and remote fetching. It acts as a wrapper around `MemoryCache` to prevent exposing generics
/// in the public API.
public struct ImageService: ImageServicing {
    let imageCache: any ImageMemoryCache

    /// Initializes the service with a network client for remote image fetching.
    ///
    /// - Parameter networkClient: The `HTTPClient` used for fetching images remotely.
    public init(networkClient: HTTPClientProtocol) {
        self.imageCache = MemoryCache(
            remoteRepository: ImageRepository(
                networkClient: networkClient
            )
        )
    }

    nonisolated public func fetchImage(_ path: String) async throws -> Image {
        Image(uiImage: try await imageCache.read(path).uiImage())
    }

    public func emptyCache() async {
        await imageCache.emptyCache()
    }
}
