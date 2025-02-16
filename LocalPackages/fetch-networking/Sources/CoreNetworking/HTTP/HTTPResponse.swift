import Foundation

public struct HTTPResponse<T: Sendable>: Sendable {
    public var value: T
    public var data: Data
    public var response: URLResponse


    public init(
        value: T,
        data: Data,
        response: URLResponse
    ) {
        self.value = value
        self.data = data
        self.response = response
    }
}
