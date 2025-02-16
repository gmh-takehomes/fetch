import SwiftUI
import Recipes

struct RecipeList: View {
    @State var viewModel: RecipeListViewModel

    var body: some View {
        NavigationStack {
            recipeList
                .navigationTitle("Recipes")
                .toolbarMenu(viewModel: viewModel)
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(
                        viewModel: RecipeDetailViewModel(
                            recipe: recipe,
                            imageService: viewModel.imageService
                        )
                    )
                }
        }
        .task {
            await viewModel.fetchRecipes()
        }
    }

    @ViewBuilder
    private var recipeList: some View {
        Group {
            switch viewModel.filteredRecipes {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            case let .loaded(recipes):
                List(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRowView(
                            viewModel: RecipeRowViewModel(
                                recipe: recipe,
                                imageService: viewModel.imageService
                            )
                        )
                    }
                }

            case .empty:
                ScrollView {
                    EmptyRecipeView()
                }
            case .failed:
                ScrollView {
                    FailureView()
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .refreshable {
            await viewModel.fetchRecipes()
        }
    }
}


// MARK: - Other Status Views

struct FailureView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 30.0)
            Text("Failed to load recipes")
                .font(.headline)
            Text("Please pulldown to try again")
                .font(.callout)
        }
    }
}

struct EmptyRecipeView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 30.0)
            Text("Oops looks like we don't have any recipes")
                .font(.headline)
            Text("Please pulldown to try again")
                .font(.callout)
        }
    }
}

