import CoreNetworking
import Foundation
import NetworkHelpers

public final class RecipeRepository: RemoteRepository {
    let networkClient: HTTPClientProtocol

    public init(networkClient: HTTPClientProtocol) {
        self.networkClient = networkClient
    }

    public nonisolated func fetch(_ path: String) async throws -> [Recipe] {
        let request: HTTPRequest<RecipeResponse> = .get(path)
        return try await networkClient.send(request: request).value.recipes
    }
}

/// Lossy Decodable Response object that will skip over malformed ``Recipe`` objects if they exist
struct RecipeResponse: Decodable, Sendable {
    @LossyDecodableArray
    public var recipes: [Recipe]
}
