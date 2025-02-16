import Testing
import NetworkMocks
import CoreNetworking
@testable import Recipes
import Foundation


struct RecipeRepositoryTests {
    @Test func fetchRecipes() async throws {
        let expectedData = try Bundle.data(fromJSONFileNamed: "recipes")
        let expectedValue = try JSONDecoder().decode(RecipeResponse.self, from: expectedData)

        let expectedPath = "/recipes.json"
        let httpClient = MockHTTPClient<RecipeResponse>(sendCallback: { request in
            #expect(request.method.rawValue == "GET")
            #expect(request.path == expectedPath)

            return HTTPResponse(
                value: expectedValue,
                data: expectedData,
                response: .init()
            )
        })

        let sut = RecipeRepository(networkClient: httpClient)

        let recipes = try await sut.fetch(expectedPath)
        #expect(recipes == expectedValue.recipes)
        #expect(recipes.count == 63)
    }

    @Test func fetchMalformedRecipes() async throws {
        let expectedData = try Bundle.data(fromJSONFileNamed: "recipes-malformed")
        let expectedValue = try JSONDecoder().decode(RecipeResponse.self, from: expectedData)

        let expectedPath = "/recipes.json"
        let httpClient = MockHTTPClient<RecipeResponse>(sendCallback: { request in
            #expect(request.method.rawValue == "GET")
            #expect(request.path == expectedPath)

            return HTTPResponse(
                value: expectedValue,
                data: expectedData,
                response: .init()
            )
        })

        let sut = RecipeRepository(networkClient: httpClient)

        let recipes = try await sut.fetch(expectedPath)
        #expect(recipes == expectedValue.recipes)
        #expect(recipes.count == 60)
    }
}
