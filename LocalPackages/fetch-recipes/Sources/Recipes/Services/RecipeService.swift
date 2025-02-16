import CoreNetworking

typealias RecipeMemoryCache = GenericCache<String, [Recipe]>
typealias RecipeRemoteRepository = RemoteRepository<String, [Recipe]>

/// A service responsible for fetching recipes.
public protocol RecipeServicing: Sendable {
    /// Fetch Image for given path
    /// - Parameters:
    ///    - requestType: ``RecipeService.RequestType`` representing the different test data
    /// - Returns: ``[Recipe]``
    nonisolated func fetchRecipes(
        _ requestType: RecipeService.RequestType // only needed for switching endpoints on the fly
    ) async throws -> [Recipe]
}

public struct RecipeService: RecipeServicing {
    let recipeCache: any RecipeMemoryCache

    public init(networkClient: HTTPClientProtocol) {
        self.recipeCache = MemoryCache(
            remoteRepository: RecipeRepository(
                networkClient: networkClient
            )
        )
    }

    /// Internal for Testing
    init(
        imageCache: any RecipeMemoryCache
    ) {
        self.recipeCache = imageCache
    }

    nonisolated public func fetchRecipes(
        _ requestType: RequestType
    ) async throws -> [Recipe] {
        guard requestType != .completeFailure else { throw MockError.completeFailure}
        return try await recipeCache.read(requestType.path)
    }
}

/// Only needed for debugging purposes these paths would be hardcoded into the specific requests that the
/// ``RecipeService`` can make
extension RecipeService {
    enum Path {
        static let recipes: String = "/recipes.json"
        static let malformedRecipes: String = "/recipes-malformed.json"
        static let emptyrecipes: String = "/recipes-empty.json"
    }

    public enum RequestType: Sendable {
        case allRecipes
        case malformedRecipes
        case emptyRecipes
        case completeFailure

        var path: String {
            switch self {
            case .allRecipes:
                return Path.recipes
            case .malformedRecipes:
                return Path.malformedRecipes
            case .emptyRecipes:
                return Path.emptyrecipes
            case .completeFailure:
                return ""
            }
        }
    }
}

public extension RecipeService {
    enum MockError: Error {
        case completeFailure
    }
}
