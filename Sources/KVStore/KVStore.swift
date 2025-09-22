import Foundation
import SwiftData
import os

/// A thread-safe and light-weight persistent key-value store built on top of SwiftData.
public actor KVStore {
    
    private let modelContext: ModelContext
    private let logger: Logger
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    /// Initializes a new instance of `KVStore`.
    /// - Parameters:
    ///  - name: The name of the store. Default is `kv_store`.
    ///  - isStoredInMemoryOnly: If `true`, the store will be stored in memory only. Default is `false`.
    ///  - subsystem: The subsystem identifier for logging. Default is `KVStore`.
    ///  - category: The category for logging. Default is `persistence`.
    public init(name: String = "kv_store", isStoredInMemoryOnly: Bool = false, subsystem: String = "KVStore", category: String = "persistence") {
        let schema = Schema([KeyValueModel.self])
        let modelConfiguration = ModelConfiguration(
            name,
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: modelConfiguration)
            self.modelContext = ModelContext(modelContainer)
            self.logger = Logger(subsystem: subsystem, category: category)
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
            logger.error("Failed to fetch model for key '\(key)': \(error.localizedDescription)")
            return nil
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
            let decodedData = try jsonDecoder.decode(type, from: model.value)
            return decodedData
        } catch let error {
            logger.error("Failed to decode value for key '\(key)': \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Retrieves values for multiple keys of the same data type.
    /// - Parameters:
    ///  - type: The expected type of the stored values, must conform to `Codable`.
    ///  - keys: An array of keys to look up.
    /// - Returns: A dictionary with keys mapped to their decoded values of type `T` if found and successfully decoded, `nil` otherwise.
    public func getValues<T: Codable>(_ type: T.Type, keys: [String]) -> [String: T]? {
        let fetchDescriptor = FetchDescriptor<KeyValueModel>(predicate: #Predicate<KeyValueModel> { keys.contains($0.key) })
        do {
            let models = try self.modelContext.fetch(fetchDescriptor)
            var result = [String: T]()
            
            for model in models {
                if let decodedValue = try? jsonDecoder.decode(type, from: model.value) {
                    result[model.key] = decodedValue
                }
            }
            
            return result.isEmpty ? nil : result
        } catch let error {
            logger.error("Failed to fetch values for keys \(keys): \(error.localizedDescription)")
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
            let encodedData = try jsonEncoder.encode(value)
            let model = try fetchModel(key: key)
            if let model {
                model.value = encodedData
            } else {
                let newModel = KeyValueModel(key: key, value: encodedData)
                self.modelContext.insert(newModel)
            }
            try modelContext.save()
        } catch let error {
            logger.error("Failed to set value for key '\(key)': \(error.localizedDescription)")
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
            logger.error("Failed to delete value for key '\(key)': \(error.localizedDescription)")
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
            logger.error("Failed to clear all values: \(error.localizedDescription)")
        }
    }
}
