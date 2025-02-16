import SwiftUI
import NetworkHelpers
import Recipes

@Observable
@MainActor
final class RecipeListViewModel: Sendable {
    var searchText: String = ""
    var recipes: LoadableArray<Recipe> = .loading

    private var networkSim: RecipeService.RequestType = .allRecipes

    func changeNetworkStatus(to status: RecipeService.RequestType) async {
        self.networkSim = status
        await fetchRecipes()
    }

    let imageService: RecipeImageServicing
    private let recipeService: RecipeServicing

    init(
        imageService: RecipeImageServicing,
        recipeService: RecipeServicing
    ) {
        self.imageService = imageService
        self.recipeService = recipeService
    }

    var filteredRecipes: LoadableArray<Recipe> {
        guard !searchText.isEmpty else { return recipes }

        if case let .loaded(recipes) = recipes {
            let filtered = recipes.filter {
                return $0.name.contains(searchText)
            }
            return .loaded(filtered)
        } else {
            return .failed
        }
    }

    nonisolated func emptyCache() async {
        await imageService.emptyCache()
    }

    func fetchRecipes() async {
        recipes = await LoadableArray {
            try await recipeService.fetchRecipes(networkSim)
        }
    }
}
