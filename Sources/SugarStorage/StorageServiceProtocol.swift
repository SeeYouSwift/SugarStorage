import Foundation

/// Protocol for file-based persistent storage.
/// Conform to this to enable mock injection in tests.
public protocol SugarStorageProtocol: Sendable {

    /// Save a `Codable` value as a JSON file under the given key.
    func save<T: Encodable & Sendable>(_ value: T, forKey key: String) throws

    /// Load and decode a `Codable` value for the given key.
    func load<T: Decodable & Sendable>(forKey key: String, as type: T.Type) throws -> T

    /// Save raw `Data` under the given key (e.g. image bytes).
    func saveData(_ data: Data, forKey key: String) throws

    /// Load raw `Data` for the given key.
    func loadData(forKey key: String) throws -> Data

    /// Delete the file for the given key.
    func delete(forKey key: String) throws

    /// Returns `true` if data exists for the given key.
    func exists(forKey key: String) -> Bool
}
