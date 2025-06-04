<h1>
KVStore 
  <img src="https://img.shields.io/badge/Swift-6.0-f05138?style=flat&labelColor=grey&logo=swift" alt="Badge">
  <a href="https://github.com/nealarch01/KVStore/actions/workflows/swift.yml">
    <img src="https://github.com/nealarch01/KVStore/actions/workflows/swift.yml/badge.svg" alt="Swift">
  </a>
</h1>

A lightweight and thread-safe persistent key-value storage built on top of SwiftData.

## Supported Platforms:
<table>
  <tr>
    <th>Platform</th>
    <th>Minimum Target Version</th>
  </tr>
  <tr>
    <td>iOS</td>
    <td>18.0</td>
  </tr>
    <tr>
    <td>macOS</td>
    <td>15.0</td>
  </tr>
  <tr>
    <td>watchOS</td>
    <td>11.0</td>
  </tr>
  <tr>
    <td>visionOS</td>
    <td>2.0</td>
  </tr>
  <tr>
    <td>tvOS</td>
    <td>18.0</td>
  </tr>
</table>

## Installation
To install this package, use Swift Package Manager.

1. Open Xcode and in the menu bar, select **File > Add Package Dependencies**.
2. In the dialog box, paste `https://github.com/nealarch01/KVStore` in the search bar at the top right.
3. Lastly, add the package to your app's target(s).

## Usage Examples
### Basic Usage
```swift
// Create a KVStore instance
let store = KVStore()

// Store simple values
await store.setValue(key: "username", value: "john_doe")
await store.setValue(key: "user_id", value: 12345)
await store.setValue(key: "is_premium", value: true)

// Retrieve values
let username = await store.getValue(String.self, key: "username") // "john_doe"
let userId = await store.getValue(Int.self, key: "user_id") // 12345
let isPremium = await store.getValue(Bool.self, key: "is_premium") // true
```

### Complex Objects
```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// Store a custom object
let user = User(id: 1, name: "Alice", email: "alice@example.com")
await store.setValue(key: "current_user", value: user)

// Retrieve the object
if let savedUser = await store.getValue(User.self, key: "current_user") {
    print("Welcome back, \(savedUser.name)!")
}
```

### Arrays and Collections
```swift
// Store arrays
let favorites = ["apple", "banana", "orange"]
await store.setValue(key: "favorite_fruits", value: favorites)

// Retrieve arrays
let savedFavorites = await store.getValue([String].self, key: "favorite_fruits")

// Store dictionaries
let settings = ["theme": "dark", "language": "en"]
await store.setValue(key: "app_settings", value: settings)
```

## Contributions
All contributions are welcome!
- **Ideas/Bugs**: If you have an idea for a new feature, or encountered a bug, open a new Issue. Describe it clearly and include any steps to reproduce if it's a bug.
- **Pull Requests**: Keep them simple and handle one feature/bug at a time. Additionally, make sure the title and description is clear and descriptive.
