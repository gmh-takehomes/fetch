import Foundation
import CoreNetworking

public typealias SendCallback<U> = @Sendable (HTTPRequest<U>) -> HTTPResponse<U>
public typealias SendDataCallback<U> =  @Sendable (HTTPRequest<Data>) -> HTTPResponse<Data>

public actor MockHTTPClient<U: Sendable>: HTTPClientProtocol {
    private let sendCallback: SendCallback<U>?
    private let sendDataCallback: SendDataCallback<U>?

    public var callbackCount: Int = 0
    public var dataCallbackCount: Int = 0

    public init(
        sendCallback: SendCallback<U>? = nil,
        sendDataCallback: SendDataCallback<U>? = nil
    ) {
        self.sendCallback = sendCallback
        self.sendDataCallback = sendDataCallback
    }

    public func send<T>(
        request: HTTPRequest<T>
    ) async throws -> HTTPResponse<T> where T: Decodable {
        guard type(of: T.self) == type(of: U.self) else {
            throw Errors.typeTandUMismatch
        }

        callbackCount += 1
        guard let sendCallback else {
            throw Errors.sendTCallbackNil
        }

        let typedRequest = request as! HTTPRequest<U>

        let response = sendCallback(typedRequest)
        let value = response.value as! T
        return HTTPResponse<T>(value: value, data: response.data, response: response.response)
    }

    public func send(request: HTTPRequest<Data>) async throws -> HTTPResponse<Data> {
        dataCallbackCount += 1

        guard let sendDataCallback else {
            throw Errors.sendDataCallbackNil
        }
        return sendDataCallback(request)
    }
}

public extension MockHTTPClient {
    enum Errors: Error {
        case sendTCallbackNil
        case sendDataCallbackNil
        case typeTandUMismatch
    }
}
