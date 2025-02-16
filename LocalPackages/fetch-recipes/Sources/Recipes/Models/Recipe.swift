import Foundation

public struct Recipe: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let cuisine: String
    public let name: String
    public let photoUrlLarge: URL?
    public let photoUrlSmall: URL?
    public let sourceUrl: URL?
    public let youtubeUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }

    init(
        id: UUID,
        cuisine: String,
        name: String,
        photoUrlLarge: URL?,
        photoUrlSmall: URL?,
        sourceUrl: URL?,
        youtubeUrl: URL?
    ) {
        self.id = id
        self.cuisine = cuisine
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
}
