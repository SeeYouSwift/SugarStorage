import Foundation

/// File-based persistent storage backed by the Application Support directory.
/// Keys support slash-separated paths (`"cache/images/thumb"`) for nested directories.
public final class SugarStorage: SugarStorageProtocol, @unchecked Sendable {

    private let fileManager: FileManagerSession
    private let baseDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        fileManager: FileManagerSession = FileManager.default,
        directoryName: String = "SugarStorage",
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder

        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        self.baseDirectory = appSupport.appendingPathComponent(directoryName)

        try? fileManager.createDirectoryIfNeeded(at: baseDirectory)
    }

    /// Internal init for tests to inject a custom base directory.
    init(
        fileManager: FileManagerSession,
        baseDirectory: URL,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.fileManager = fileManager
        self.baseDirectory = baseDirectory
        self.encoder = encoder
        self.decoder = decoder
        try? fileManager.createDirectoryIfNeeded(at: baseDirectory)
    }

    // MARK: - SugarStorageProtocol

    public func save<T: Encodable & Sendable>(_ value: T, forKey key: String) throws {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw StorageError.encodingFailed(error.localizedDescription)
        }
        try saveData(data, forKey: key)
    }

    public func load<T: Decodable & Sendable>(forKey key: String, as type: T.Type) throws -> T {
        let data = try loadData(forKey: key)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw StorageError.decodingFailed(error.localizedDescription)
        }
    }

    public func saveData(_ data: Data, forKey key: String) throws {
        let url = fileURL(forKey: key)
        let parentDir = url.deletingLastPathComponent()
        try fileManager.createDirectoryIfNeeded(at: parentDir)
        do {
            try fileManager.write(data, to: url)
        } catch {
            throw StorageError.writeFailed(error.localizedDescription)
        }
    }

    public func loadData(forKey key: String) throws -> Data {
        let url = fileURL(forKey: key)
        guard fileManager.fileExists(at: url) else {
            throw StorageError.fileNotFound(key)
        }
        return try fileManager.read(from: url)
    }

    public func delete(forKey key: String) throws {
        let url = fileURL(forKey: key)
        guard fileManager.fileExists(at: url) else { return }
        try fileManager.delete(at: url)
    }

    public func exists(forKey key: String) -> Bool {
        fileManager.fileExists(at: fileURL(forKey: key))
    }

    // MARK: - Private

    private func fileURL(forKey key: String) -> URL {
        baseDirectory.appendingPathComponent(key)
    }
}
