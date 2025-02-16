import Testing
import NetworkMocks
import CoreNetworking
@testable import Recipes
import UIKit
import SwiftUI

extension Recipe {
    static var mock: Recipe {
        return .init(
            id: UUID(uuidString: "404003cd-2a5f-46e5-a29e-57ffda0ad133")!,
            cuisine: "Mock Cuisine",
            name: "Spaghetti Carbonara",
            photoUrlLarge: URL(filePath: "/large.jpg"),
            photoUrlSmall: URL(filePath: "/small.jpg"),
            sourceUrl: URL(filePath: ""),
            youtubeUrl: URL(filePath: "")
        )
    }

    static var badURLs: Recipe {
        return .init(
            id: UUID(uuidString: "404003cd-2a5f-46e5-a29e-57ffda0ad133")!,
            cuisine: "Mock Title",
            name: "large.jpg",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            sourceUrl: nil,
            youtubeUrl: nil
        )
    }
}

struct RecipeImageServiceTests {
    @Test func largeImage_verifyNetworkIsCalledOnce() async throws {
        let expectedPath = "/large.jpg"

        let imageService = MockImageService { path in
            #expect(path == expectedPath)
            return Image(uiImage: UIImage(color: .red)!)
        }

        let sut = RecipeImageService(imageService: imageService)

        let image = try await sut.fetchLargeImage(Recipe.mock)
        #expect(image != nil)
    }

    @Test func smallImage_verifyNetworkIsCalledOnce() async throws {
        let expectedPath = "/small.jpg"

        let imageService = MockImageService { path in
            #expect(path == expectedPath)
            return Image(uiImage: UIImage(color: .red)!)
        }

        let sut = RecipeImageService(imageService: imageService)

        let image = try await sut.fetchSmallImage(Recipe.mock)
        #expect(image != nil)
    }

    @Test func example_emptyCache() async throws {
        await confirmation(
            "…",
            expectedCount: 1
          ) { cacheEmptied in
              let imageService = MockImageService(emptyCacheCallBack: {
                  cacheEmptied()
              })

              let sut = RecipeImageService(imageService: imageService)

              await sut.emptyCache()
          }
    }

    @Test func example_badImageData() async throws {
        let expectedPath = "/small.jpg"

        let httpClient = MockHTTPClient<Data>(sendDataCallback: { request in
            #expect(request.method.rawValue == "GET")
            #expect(request.path == expectedPath)

            let imageData = Data()
            return HTTPResponse(
                value: imageData,
                data: imageData,
                response: .init()
            )
        })
        let imageService = ImageService(networkClient: httpClient)
        let sut = RecipeImageService(imageService: imageService)

        await #expect(throws: CodableUIImage.UIImageError.invalidData) {
            try await sut.fetchSmallImage(.mock)
        }
    }

    @Test func example_badURLData() async throws {
        let httpClient = MockHTTPClient<Data>()
        let imageService = ImageService(networkClient: httpClient)
        let sut = RecipeImageService(imageService: imageService)

        await #expect(throws: RecipeImageService.Errors.URLNotFound) {
            try await sut.fetchSmallImage(.badURLs)
        }
        await #expect(throws: RecipeImageService.Errors.URLNotFound) {
            try await sut.fetchLargeImage(.badURLs)
        }
    }
}
