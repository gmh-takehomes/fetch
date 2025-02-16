import CoreNetworking
import SwiftUI

/// A service responsible for fetching recipe images.
public protocol RecipeImageServicing: Sendable {
    /// Fetches the small-sized image for a given recipe.
    ///
    /// - Parameter recipe: The `Recipe` for which the small image is being fetched.
    /// - Returns: The corresponding small `Image`.
    nonisolated func fetchSmallImage(_ recipe: Recipe) async throws -> Image

    /// Fetches the large-sized image for a given recipe.
    ///
    /// - Parameter recipe: The `Recipe` for which the large image is being fetched.
    /// - Returns: The corresponding large `Image`.
    nonisolated func fetchLargeImage(_ recipe: Recipe) async throws -> Image

    /// Clears any cached images stored by the service and its underlying services.
    func emptyCache() async
}

/// A specialized service for fetching images associated with recipes.
///
/// ``RecipeImageService`` provides a recipe-specific interface for retrieving small and large images.
/// It uses the ``ImageServicing`` for the image fetching and caching responsibilies
///
/// - Note: This service does not manage image storage itself but relies on `ImageServicing` for caching and retrieval.
///
/// - Remark: This demonstrates how services can be composed to provide domain-specific functionality
/// without exposing implementation details.
public struct RecipeImageService: RecipeImageServicing {
    let imageService: any ImageServicing

    public init(imageService: any ImageServicing) {
        self.imageService = imageService
    }

    nonisolated public func fetchSmallImage(_ recipe: Recipe) async throws -> Image {
        guard let path = recipe.photoUrlSmall?.path() else {
            throw Errors.URLNotFound
        }
        return try await imageService.fetchImage(path)
    }

    nonisolated public func fetchLargeImage(_ recipe: Recipe) async throws -> Image {
        guard let path = recipe.photoUrlLarge?.path() else {
            throw Errors.URLNotFound
        }
        return try await imageService.fetchImage(path)
    }

    public func emptyCache() async {
        await imageService.emptyCache()
    }
}

extension RecipeImageService {
    enum Errors: Error {
        case URLNotFound
    }
}
