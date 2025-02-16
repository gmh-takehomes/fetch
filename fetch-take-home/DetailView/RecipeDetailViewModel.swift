import Recipes
import NetworkHelpers
import SwiftUI

@Observable
@MainActor
final class RecipeDetailViewModel: Sendable {
    let recipe: Recipe
    let imageService: RecipeImageServicing

    var image: Loadable<Image> = .loading

    init(
        recipe: Recipe,
        imageService: RecipeImageServicing
    ) {
        self.recipe = recipe
        self.imageService = imageService
    }

    func fetchImage() async {
        do {
            let image = try await imageService.fetchLargeImage(recipe)
            self.image = .loaded(image)
        } catch {
            image = .failed
        }
    }
}
