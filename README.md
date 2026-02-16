# SugarStorage

File-based persistent storage for Swift. Saves `Codable` values and raw `Data` to the Application Support directory with a simple key-based API. Fully protocol-driven for easy unit testing.

## Features

- Save and load any `Codable` type
- Raw `Data` read/write for binary content (images, files, etc.)
- Nested key paths (`"cache/images/thumb"`) automatically create directory structure
- Configurable directory name, encoder, and decoder
- Injectable `FileManagerSession` for hermetic tests

## Requirements

- iOS 18+ / macOS 15+
- Swift 6+

## Installation

### Swift Package Manager

**Via Xcode:**
1. File → Add Package Dependencies
2. Enter the repository URL:
   ```
   https://github.com/SeeYouSwift/SugarStorage
   ```
3. Select version rule and click **Add Package**

**Via `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/SeeYouSwift/SugarStorage", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SugarStorage"]
    ),
    // For test targets — add the mock library:
    .testTarget(
        name: "YourTargetTests",
        dependencies: [
            "YourTarget",
            .product(name: "SugarStorageMocks", package: "SugarStorage")
        ]
    )
]
```
## Usage

### Save and Load a Codable Value

```swift
import SugarStorage

struct UserSettings: Codable {
    var darkMode: Bool
    var fontSize: Int
}

let storage = SugarStorage(directoryName: "MyApp")

// Save
try storage.save(UserSettings(darkMode: true, fontSize: 16), forKey: "settings/user")

// Load
let settings = try storage.load(forKey: "settings/user", as: UserSettings.self)
```

### Raw Data

```swift
let data = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
try storage.saveData(data, forKey: "cache/header.bin")

let loaded = try storage.loadData(forKey: "cache/header.bin")
```

### Check Existence and Delete

```swift
if storage.exists(forKey: "settings/user") {
    try storage.delete(forKey: "settings/user")
}
```

### Dependency Injection

```swift
final class SettingsRepository {
    private let storage: SugarStorageProtocol

    init(storage: SugarStorageProtocol = SugarStorage(directoryName: "MyApp")) {
        self.storage = storage
    }

    func saveSettings(_ settings: UserSettings) throws {
        try storage.save(settings, forKey: "settings/user")
    }
}
```

### Testing

```swift
import SugarStorageMocks

let mock = MockStorageService()
mock.shouldThrowOnSave = false

let repo = SettingsRepository(storage: mock)
try repo.saveSettings(UserSettings(darkMode: false, fontSize: 14))

XCTAssertEqual(mock.saveCallCount, 1)
```

## API Reference

### `SugarStorageProtocol`

```swift
func save<T: Encodable & Sendable>(_ value: T, forKey key: String) throws
func load<T: Decodable & Sendable>(forKey key: String, as type: T.Type) throws -> T
func saveData(_ data: Data, forKey key: String) throws
func loadData(forKey key: String) throws -> Data
func delete(forKey key: String) throws
func exists(forKey key: String) -> Bool
```

### `StorageError`

| Case | Description |
|------|-------------|
| `.fileNotFound(String)` | No file exists for the given key |
| `.encodingFailed(String)` | `JSONEncoder` threw an error |
| `.decodingFailed(String)` | `JSONDecoder` threw an error |
| `.writeFailed(String)` | File system write failed |

### `SugarStorage` Initializer

| Parameter | Default | Description |
|-----------|---------|-------------|
| `directoryName` | `"SugarStorage"` | Subdirectory inside Application Support |
| `encoder` | `JSONEncoder()` | Custom encoding strategy |
| `decoder` | `JSONDecoder()` | Custom decoding strategy |
| `fileManager` | `FileManager.default` | Injectable for tests |

## Storage Location

Files are stored at:

```
~/Library/Application Support/{directoryName}/{key}
```

Keys support slashes for nested paths. Parent directories are created automatically.
