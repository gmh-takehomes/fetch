public typealias CodableSendable = Codable & Sendable
public typealias HashableSendable = Hashable & Sendable

/// A generic protocol defining caching behavior for key-value storage.
public protocol GenericCache<Key, T>: Sendable where Key: HashableSendable, T: CodableSendable {
    associatedtype Key
    associatedtype T

    func read(_ key: Key) async throws -> T

    /// Clears all cached data.
    func emptyCache() async
}
