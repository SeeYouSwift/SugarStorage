import Foundation

public enum StorageError: LocalizedError, Equatable {
    case fileNotFound(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case writeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let key):
            "File not found: \(key)"
        case .encodingFailed(let message):
            "Encoding error: \(message)"
        case .decodingFailed(let message):
            "Decoding error: \(message)"
        case .writeFailed(let message):
            "Write error: \(message)"
        }
    }
}
