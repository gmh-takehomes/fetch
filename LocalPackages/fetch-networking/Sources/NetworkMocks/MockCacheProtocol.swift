import CoreNetworking

public typealias ReadCallBack<Key, T> = (Key) async throws -> T

public actor MockGenericCache<Key, T>: GenericCache where Key: HashableSendable, T: CodableSendable {
    private let readCallBack: ReadCallBack<Key, T>
    private let emptyCacheCallBack: () -> Void

    public init(
        readCallBack: @escaping ReadCallBack<Key, T>,
        emptyCacheCallBack: @escaping () -> Void = {}
    ) {
        self.readCallBack = readCallBack
        self.emptyCacheCallBack = emptyCacheCallBack
    }

    public func read(_ key: Key) async throws -> T {
        try await readCallBack(key)
    }

    public func emptyCache() async {
        emptyCacheCallBack()
    }
}
