import Testing
import NetworkMocks
@testable import CoreNetworking
import UIKit

struct ImageServiceTests {
    @Test func verifyNetworkIsCalledOnce() async throws {
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

        let sut = ImageService(networkClient: httpClient)

        var image = try await sut.fetchImage(expectedPath)
        #expect(image != nil)

        image = try await sut.fetchImage(expectedPath)
        #expect(image != nil)

        #expect(await httpClient.callbackCount == 0)
        #expect(await httpClient.dataCallbackCount == 1)

    }

    @Test func example_emptyCache() async throws {
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

        let sut = ImageService(networkClient: httpClient)

        var image = try await sut.fetchImage(expectedPath)
        #expect(image != nil)
        #expect(await httpClient.dataCallbackCount == 1)

        await sut.emptyCache()

        image = try await sut.fetchImage(expectedPath)
        #expect(image != nil)

        #expect(await httpClient.callbackCount == 0)
        #expect(await httpClient.dataCallbackCount == 2)
    }

    @Test func example_badImageData() async throws {
        let expectedPath = "/bad_data.jpg"

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

        let sut = ImageService(networkClient: httpClient)

        await #expect(throws: CodableUIImage.UIImageError.invalidData) { try await sut.fetchImage(expectedPath) }
    }
}
