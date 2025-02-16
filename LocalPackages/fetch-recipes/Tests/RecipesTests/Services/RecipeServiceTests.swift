import Testing
import CoreNetworking
@testable import Recipes
import NetworkMocks
import UIKit

struct RecipeServiceTests {
    @Test(
        "Continents mentioned in videos",
        arguments: [
            RecipeService.RequestType.allRecipes,
            RecipeService.RequestType.malformedRecipes,
            RecipeService.RequestType.emptyRecipes,
            RecipeService.RequestType.completeFailure,
        ]
    )
    func testFetchRecipes_ReturnsRecipeFromCache(type: RecipeService.RequestType) async throws {
        let expectedKey: String
        switch type {
        case .allRecipes:
            expectedKey = "/recipes.json"
        case .malformedRecipes:
            expectedKey = "/recipes-malformed.json"
        case .emptyRecipes:
            expectedKey = "/recipes-empty.json"
        case .completeFailure:
            expectedKey = ""
        }

        let cache = MockGenericCache<String, [Recipe]>(readCallBack: { key in
            #expect(key == expectedKey)
            return type != .emptyRecipes ? [Recipe.mock] : []
        })

        let sut = RecipeService(
            imageCache: cache
        )


        switch type {
        case .allRecipes, .malformedRecipes:
            let result = try await sut.fetchRecipes(type)
            #expect(result.count == 1)
            #expect(result.first?.name == "Spaghetti Carbonara")
            #expect(result.first?.cuisine == "Mock Cuisine")
        case .emptyRecipes:
            let result = try await sut.fetchRecipes(type)
            #expect(result.count == 0)
        case .completeFailure:
            await #expect(throws: RecipeService.MockError.completeFailure) {
                try await sut.fetchRecipes(.completeFailure)
            }
        }
    }
}

