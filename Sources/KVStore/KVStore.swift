import Foundation
import SwiftData

/// A thread-safe and light-weight persistent key-value store built on top of SwiftData.
public actor KVStore {
    
    private var modelContext: ModelContext
    private var consoleLoggingEnabled: Bool

    /// Initializes a new instance of `KVStore`.
    /// - Parameters:
    ///  - name: The name of the store. Default is `kv_store`.
    ///  - inMemory: If `true`, the store will be stored in memory only. Default is `false`.
    ///  - consoleLoggingEnabled: If `true`, console logging will be enabled. Default is `false`.
    public init(name: String = "kv_store", inMemory: Bool = false, consoleLoggingEnabled: Bool = false) {
        let schema = Schema([KeyValueModel.self])
        let modelConfiguration = ModelConfiguration(
            name,
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: modelConfiguration)
            self.modelContext = ModelContext(modelContainer)
            self.consoleLoggingEnabled = consoleLoggingEnabled
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    internal func fetchModel(key: String) throws -> KeyValueModel? {
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<KeyValueModel> { $0.key == key })
        do {
            let model = try self.modelContext.fetch(fetchDescriptor).first
            return model
        } catch let error {
            logError(error)
            return nil
        }
    }
    
    private func log(_ message: String, _ function: String = #function) {
        if consoleLoggingEnabled {
            print("💾 KVStore: \(message)")
        }
    }
    
    private func logError(_ error: Error, _ function: String = #function) {
        if consoleLoggingEnabled {
            print("💾 KVStore Error in \(function): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Interface
    
    /// Retrieves a value for a given key.
    /// - Parameters:
    ///   - type: The expected type of the stored value, must conform to `Codable`.
    ///   - key: The key to look up.
    /// - Returns: The decoded value of type `T` if found and successfully decoded, `nil` otherwise.
    public func getValue<T: Codable>(_ type: T.Type, key: String) -> T? {
        do {
            guard let model = try self.fetchModel(key: key) else { return nil }
            let decodedData = try JSONDecoder().decode(type, from: model.value)
            return decodedData
        } catch let error {
            logError(error)
            return nil
        }
    }
    
    /// Stores a value with the given key.
    /// - Parameters:
    ///   - key: The key to associate with the value.
    ///   - value: The value to store, must conform to `Codable`.
    /// - Note: Updates the value if the key already exists.
    public func setValue<T: Codable>(key: String, value: T) {
        do {
            let encodedData = try JSONEncoder().encode(value)
            let model = try fetchModel(key: key)
            if let model {
                model.value = encodedData
            } else {
                let newModel = KeyValueModel(key: key, value: encodedData)
                self.modelContext.insert(newModel)
            }
            try modelContext.save()
        } catch let error {
            logError(error)
        }
    }
    
    /// Deletes a value with the given key.
    /// - Parameter key: The key to delete.
    public func deleteValue(key: String) {
        do {
            guard let model = try self.fetchModel(key: key) else { return }
            self.modelContext.delete(model)
            try self.modelContext.save()
        } catch let error {
            logError(error)
        }
    }
    
    /// Removes all stored key-value pairs.
    public func clear() {
        do {
            let fetchDescriptor = FetchDescriptor<KeyValueModel>()
            let models = try self.modelContext.fetch(fetchDescriptor)
            for model in models {
                self.modelContext.delete(model)
            }
            try self.modelContext.save()
        } catch let error {
            logError(error)
        }
    }
}
