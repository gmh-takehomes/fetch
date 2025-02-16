import SwiftUI

struct RecipeDetailView: View {
    @State var viewModel: RecipeDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.recipe.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)

            Text(viewModel.recipe.cuisine)
                .font(.title2)
                .foregroundColor(.secondary)

            image

            links

            Spacer()
        }
        .padding()
        .task {
            await viewModel.fetchImage()
        }
    }

    @ViewBuilder
    private var image: some View {
        Group {
            switch viewModel.image {
            case .loading:
                ZStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    Color.gray.opacity(0.1)
                }
            case .loaded(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failed:
                ZStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    Color.gray.opacity(0.1)
                }
            }
        }
        .frame(height: 250, alignment: .center)
        .cornerRadius(15)
        .shadow(radius: 10)
    }

    @ViewBuilder
    private var links: some View {
        HStack {
            if let sourceUrl = viewModel.recipe.sourceUrl {
                Link("View Recipe", destination: sourceUrl)
                    .font(.body)
                    .foregroundColor(.blue)
                // Space inside if let so that single links will always be leading
                Spacer()
            }

            if let youtubeUrl = viewModel.recipe.youtubeUrl {
                Link("Watch on YouTube", destination: youtubeUrl)
                    .font(.body)
                    .foregroundColor(.blue)
            }
        }
        .padding(.top)
    }
}

