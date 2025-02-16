import Testing
import NetworkMocks
import CoreNetworking
import UIKit
import Foundation


struct ImageRepositoryTests {
    @Test func fetchImage() async throws {
        let expectedPath = "/large.jpg"

        let httpClient = MockHTTPClient<Data>(sendDataCallback: { request in
            #expect(request.method.rawValue == "GET")
            #expect(request.path == expectedPath)

            let imageData = UIImage(color: .red)!.pngData()!
            return HTTPResponse(
                value: imageData,
                data: imageData,
                response: .init()
            )
        })

        let sut = ImageRepository(networkClient: httpClient)

        let image = try await sut.fetch(expectedPath)
        #expect(image != nil)
    }
}
