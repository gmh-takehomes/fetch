import SwiftUI
import NetworkHelpers
import Recipes

struct RecipeRowView: View {
    @State var viewModel: RecipeRowViewModel

    var body: some View {
        HStack {
            imageView
            VStack(alignment: .leading) {
                Text(viewModel.recipe.name)
                    .font(.headline)
                Text(viewModel.recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await viewModel.fetchImageIfNeeded()
        }
    }

    @ViewBuilder
    private var imageView: some View {
        Group {
            switch viewModel.recipeImage {
            case .loading:
                ProgressView()
            case .loaded(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failed:
                Color.gray.opacity(0.3)
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(10)
    }
}

@Observable
@MainActor
class RecipeRowViewModel: Sendable {
    let recipe: Recipe
    var recipeImage: Loadable<Image> = .loading
    private let imageService: RecipeImageServicing

    init(
        recipe: Recipe,
        imageService: RecipeImageServicing
    ) {
        self.recipe = recipe
        self.imageService = imageService
    }

    func fetchImageIfNeeded() async {
        // This is only needed because SwiftUI's caching for upward scrolling
        guard recipeImage == .loading else { return }

        do {
            let image = try await imageService.fetchSmallImage(recipe)
            recipeImage = .loaded(image)
        } catch {
            recipeImage = .failed
        }
    }
}
