import UIKit

public struct CodableUIImage: Codable, Sendable {
    var data: Data

    public init(data: Data) {
        self.data = data
    }

    public enum UIImageError: Error {
        case invalidData
    }

    public func uiImage() throws -> UIImage {
        guard let uiImage = UIImage(data: data) else {
            throw UIImageError.invalidData
        }
        return uiImage
    }
}
