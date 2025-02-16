public enum Loadable<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case failed
}
