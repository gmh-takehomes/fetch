import SwiftUI
import CoreNetworking

public typealias MockImageReadCallBack = @Sendable (String) async throws -> Image

public actor MockImageService: ImageServicing {

    private let readCallBack: MockImageReadCallBack?
    private let emptyCacheCallBack: () -> Void

    public init(
        readCallBack: MockImageReadCallBack? = nil,
        emptyCacheCallBack: @escaping () -> Void = {}
    ) {
        self.readCallBack = readCallBack
        self.emptyCacheCallBack = emptyCacheCallBack
    }

    // Fetches an image from the cache
    public func fetchImage(_ path: String) async throws -> Image {
        guard let readCallBack else { throw URLError(.badURL) }
        return try await readCallBack(path)
    }

    // Clears the cached images
    public func emptyCache() async {
        emptyCacheCallBack()
    }
}
