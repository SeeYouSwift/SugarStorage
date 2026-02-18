import Foundation
import Testing
@testable import SugarStorage

struct SugarStorageTests {

    // MARK: - Helpers

    private func makeSUT() -> SugarStorage {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        return SugarStorage(
            fileManager: FileManager.default,
            baseDirectory: tempDir
        )
    }

    private struct TestModel: Codable, Equatable, Sendable {
        let id: Int
        let name: String
    }

    // MARK: - Save and Load Codable

    @Test func saveAndLoadCodableRoundTrips() throws {
        // Given
        let sut = makeSUT()
        let model = TestModel(id: 1, name: "Test")

        // When
        try sut.save(model, forKey: "test-model")
        let loaded = try sut.load(forKey: "test-model", as: TestModel.self)

        // Then
        #expect(loaded == model)
    }

    // MARK: - Save and Load Raw Data

    @Test func saveAndLoadDataRoundTrips() throws {
        // Given
        let sut = makeSUT()
        let data = Data("image-bytes".utf8)

        // When
        try sut.saveData(data, forKey: "image.jpg")
        let loaded = try sut.loadData(forKey: "image.jpg")

        // Then
        #expect(loaded == data)
    }

    // MARK: - Load Nonexistent Key

    @Test func loadThrowsFileNotFoundForMissingKey() throws {
        // Given
        let sut = makeSUT()

        // When / Then
        #expect(throws: StorageError.fileNotFound("missing")) {
            _ = try sut.loadData(forKey: "missing")
        }
    }

    // MARK: - Exists

    @Test func existsReturnsTrueAfterSave() throws {
        // Given
        let sut = makeSUT()

        // When
        try sut.saveData(Data("data".utf8), forKey: "check")

        // Then
        #expect(sut.exists(forKey: "check") == true)
        #expect(sut.exists(forKey: "nope") == false)
    }

    // MARK: - Delete

    @Test func deleteRemovesFile() throws {
        // Given
        let sut = makeSUT()
        try sut.saveData(Data("data".utf8), forKey: "to-delete")

        // When
        try sut.delete(forKey: "to-delete")

        // Then
        #expect(sut.exists(forKey: "to-delete") == false)
    }

    // MARK: - Overwrite

    @Test func saveOverwritesExistingData() throws {
        // Given
        let sut = makeSUT()
        try sut.save(TestModel(id: 1, name: "Old"), forKey: "model")

        // When
        try sut.save(TestModel(id: 2, name: "New"), forKey: "model")
        let loaded = try sut.load(forKey: "model", as: TestModel.self)

        // Then
        #expect(loaded == TestModel(id: 2, name: "New"))
    }

    // MARK: - Subdirectory Keys

    @Test func saveDataCreatesSubdirectories() throws {
        // Given
        let sut = makeSUT()
        let data = Data("nested".utf8)

        // When
        try sut.saveData(data, forKey: "images/abc123.dat")
        let loaded = try sut.loadData(forKey: "images/abc123.dat")

        // Then
        #expect(loaded == data)
    }

    // MARK: - Delete Nonexistent Key Does Not Throw

    @Test func deleteNonexistentKeyDoesNotThrow() throws {
        // Given
        let sut = makeSUT()

        // When / Then
        #expect(throws: Never.self) {
            try sut.delete(forKey: "nonexistent")
        }
    }
}
