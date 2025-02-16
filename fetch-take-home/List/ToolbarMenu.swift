import SwiftUI
import Recipes

struct ToolbarMenuModifier: ViewModifier {
    var viewModel: RecipeListViewModel

    func button(_ titleKey: LocalizedStringKey, changeTo type: RecipeService.RequestType) -> Button<Text> {
        .init(titleKey) {
            Task {
                await viewModel.changeNetworkStatus(to: type)
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("Network") {
                            button("All Recipes", changeTo: .allRecipes)
                            button("Malformed Data", changeTo: .malformedRecipes)
                            button("Empty Data", changeTo: .emptyRecipes)
                            button("Complete Failure", changeTo: .completeFailure)
                        }

                        Divider()

                        Button(role: .destructive) {
                            Task {
                                await viewModel.emptyCache()
                            }
                        } label: {
                            Label("Clear Cache", systemImage: "trash")
                        }
                    } label: {
                        Label("Menu", systemImage: "gear")
                    }
                }
            }
    }
}

extension View {
    func toolbarMenu(viewModel: RecipeListViewModel) -> some View {
        self.modifier(ToolbarMenuModifier(viewModel: viewModel))
    }
}
