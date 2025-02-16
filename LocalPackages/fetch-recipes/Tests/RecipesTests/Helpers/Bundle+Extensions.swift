import Foundation

public extension Bundle {
    static func data(fromJSONFileNamed file: String) throws -> Data {
        guard let dataURL = Bundle.module.url(forResource: file, withExtension: "json"),
              let rawData = try? Data(contentsOf: dataURL) else {
            throw URLError(.cancelled)
        }

        return rawData
    }
}
