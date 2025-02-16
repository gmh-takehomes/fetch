public enum LoadableArray<T: Equatable & Sendable>: Equatable, Sendable {
    case empty
    case loading
    case loaded([T])
    case failed

    public init(_ loadingAction: @Sendable () async throws -> [T]) async {
        do {
            let loadedItems = try await loadingAction()
            guard !loadedItems.isEmpty else {
                self = .empty
                return
            }
            self = .loaded(loadedItems)
        } catch {
            self = .failed
        }
    }
}
