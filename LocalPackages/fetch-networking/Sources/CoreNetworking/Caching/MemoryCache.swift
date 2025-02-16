import Foundation
/// An in-memory cache that fetches data from a remote source if not already cached.
///
/// This actor ensures that multiple concurrent requests for the same key do not result in duplicate network calls.
/// Instead, ongoing fetches are tracked in an internal dictionary, and subsequent requests await the same result.
///
/// - Remark: This approach prevents unintended actor reentrancy issues when making asynchronous calls
/// within an actor’s isolation.
///
/// - SeeAlso: Implmentation inspired by [donnywals](https://www.donnywals.com/actor-reentrancy-in-swift-explained/)
///
public actor MemoryCache<Key: HashableSendable, T: CodableSendable>: GenericCache {
    enum LoadingTask {
        case inProgress(Task<T, Error>)
        case loaded(T)
    }

    private var cache: [Key: LoadingTask] = [:]
    private let remoteRepository: any RemoteRepository<Key, T>

    private let logger: CacheLogger.Type?

    public init(
        remoteRepository: any RemoteRepository<Key, T>,
        logger: CacheLogger.Type? = CacheLogger.self
    ) {
        self.remoteRepository = remoteRepository
        self.logger = logger
    }

    public func read(_ key: Key) async throws -> T {
        // Logging
        logger?.log(.cacheStarted, key: key)
        defer {
            logger?.log(.cacheFinished, key: key)
        }

        // Return the data if it already exists in cache
        if case let .loaded(data) = cache[key] {
            return data
        }

        // Return the task.value if that fetch has already begun
        if case let .inProgress(task) = cache[key] {
            return try await task.value
        }

        // First time requesting data for that key create task
        let task: Task<T, Error> = Task {
            logger?.log(.networkStated, key: key)
            let data = try await remoteRepository.fetch(key)
            logger?.log(.netowrkFinished, key: key)
            return data
        }
        cache[key] = .inProgress(task)

        // Once task is completed add data to cache and return data
        let data = try await task.value
        cache[key] = .loaded(data)
        return data

    }

    public func emptyCache() async {
        cache.removeAll()
    }
}

public struct CacheLogger: Sendable {
    enum CacheLog {
        case cacheStarted
        case cacheFinished
        case networkStated
        case netowrkFinished
    }

    static func log<Key: HashableSendable>(_ log: CacheLog, key: Key) {
        switch log {
        case .cacheStarted:
            print("🟡 cache read called for \(key)")
        case .cacheFinished:
            print("✅ cache read finished for \(key)")
        case .networkStated:
            print("🛜 network started for \(key)")
        case .netowrkFinished:
            print("🛜 network finished for \(key)")
        }
    }
}
