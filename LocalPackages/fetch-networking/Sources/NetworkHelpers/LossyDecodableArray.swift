import Foundation
import os.log

///  by https://marksands.github.io/2019/10/21/better-codable-through-property-wrappers.html

@propertyWrapper
public struct LossyDecodableArray<Element>: Decodable & Sendable where Element: Decodable & Sendable {
    public var wrappedValue: [Element]
    private let logger: Logger = Logger()

    public init(wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }

    private struct AnyCodableValue: Codable {}

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []
        while !container.isAtEnd {
            do {
                elements.append(try container.decode(Element.self))
            } catch {
                if let decodingError = error as? DecodingError {
                    logger.error("\(decodingError)")
                }
                _ = try? container.decode(AnyCodableValue.self)
            }
        }
        self.wrappedValue = elements
    }
}
