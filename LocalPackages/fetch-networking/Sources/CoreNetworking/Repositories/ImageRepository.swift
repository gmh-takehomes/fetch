import Foundation

final public class ImageRepository: RemoteRepository {
    let networkClient: HTTPClientProtocol

    public init(networkClient: HTTPClientProtocol) {
        self.networkClient = networkClient
    }

    nonisolated public func fetch(_ key: String) async throws -> CodableUIImage {
        let response: HTTPResponse<Data> = try await networkClient.send(request: .get(key))
        return CodableUIImage(data: response.data)
    }
}
