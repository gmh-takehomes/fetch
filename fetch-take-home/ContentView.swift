import SwiftUI
import Recipes
import CoreNetworking

struct ContentView: View {
    var body: some View {
        RecipeList(
            viewModel: RecipeListViewModel(
                imageService: RecipeImageService(
                    imageService: ImageService(logging: true)
                ),
                recipeService: RecipeService(logging: true)
            )
        )
    }
}

#Preview {
    ContentView()
}
