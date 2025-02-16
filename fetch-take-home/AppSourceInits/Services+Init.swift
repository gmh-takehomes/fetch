import Recipes
import CoreNetworking

extension RecipeService {
    public init(logging: Bool) {
        self.init(
            networkClient: HTTPClient(host: "d3jbb8n5wk0qxi.cloudfront.net")
        )
    }
}

extension ImageService {
    public init(logging: Bool) {
        self.init(
            networkClient: HTTPClient(host: "d3jbb8n5wk0qxi.cloudfront.net")
        )
    }
}
