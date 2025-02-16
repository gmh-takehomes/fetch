/// A generic protocol defining a remote repository responsible for fetching data from a network source.
public protocol RemoteRepository<Key, T>: Sendable where Key : Hashable {
    associatedtype Key
    associatedtype T

    /// Fetches data from the remote repository using the provided path.
    nonisolated func fetch(_ path: Key) async throws -> T
}
