import Foundation

public protocol FileManagerSession: Sendable {
    func write(_ data: Data, to url: URL) throws
    func read(from url: URL) throws -> Data
    func delete(at url: URL) throws
    func fileExists(at url: URL) -> Bool
    func createDirectoryIfNeeded(at url: URL) throws
}

extension FileManager: FileManagerSession {

    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }

    public func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func delete(at url: URL) throws {
        try removeItem(at: url)
    }

    public func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    public func createDirectoryIfNeeded(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}
