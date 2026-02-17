import Foundation
import SugarStorage

/// In-memory mock of `SugarStorageProtocol` for unit testing.
/// Tracks call counts and supports simulated errors.
public final class MockStorageService: SugarStorageProtocol, @unchecked Sendable {

    private var store: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public var saveCallCount = 0
    public var loadCallCount = 0
    public var deleteCallCount = 0

    public var shouldThrowOnSave = false
    public var shouldThrowOnLoad = false

    public init() {}

    // MARK: - SugarStorageProtocol

    public func save<T: Encodable & Sendable>(_ value: T, forKey key: String) throws {
        saveCallCount += 1
        if shouldThrowOnSave { throw StorageError.writeFailed("Mock error") }
        store[key] = try encoder.encode(value)
    }

    public func load<T: Decodable & Sendable>(forKey key: String, as type: T.Type) throws -> T {
        loadCallCount += 1
        if shouldThrowOnLoad { throw StorageError.fileNotFound(key) }
        guard let data = store[key] else { throw StorageError.fileNotFound(key) }
        return try decoder.decode(type, from: data)
    }

    public func saveData(_ data: Data, forKey key: String) throws {
        saveCallCount += 1
        if shouldThrowOnSave { throw StorageError.writeFailed("Mock error") }
        store[key] = data
    }

    public func loadData(forKey key: String) throws -> Data {
        loadCallCount += 1
        if shouldThrowOnLoad { throw StorageError.fileNotFound(key) }
        guard let data = store[key] else { throw StorageError.fileNotFound(key) }
        return data
    }

    public func delete(forKey key: String) throws {
        deleteCallCount += 1
        store.removeValue(forKey: key)
    }

    public func exists(forKey key: String) -> Bool {
        store[key] != nil
    }
}
