import Testing
@testable import KVStore

@Suite(.serialized)
struct KVStoreTests {
    let kvStore: KVStore
    
    init() {
        self.kvStore = KVStore(name: "kv_store_tests", isStoredInMemoryOnly: true, consoleLoggingEnabled: true)
    }
    
    @Test
    func testGetSetDeleteBooleanValue() async {
        let key = "testBoolKey"
        
        // Test getting the initial value (which should be nil).
        let initialValue = await kvStore.getValue(Bool.self, key: key)
        #expect(initialValue == nil)
        
        // Test setting a boolean value to `true`.
        await kvStore.setValue(key: key, value: true)
        let secondValue = await kvStore.getValue(Bool.self, key: key)
        #expect(secondValue == true)
        
        // Test setting a boolean value to `false`.
        await kvStore.setValue(key: key, value: false)
        let thirdValue = await kvStore.getValue(Bool.self, key: key)
        #expect(thirdValue == false)
        
        // Test deleting the value.
        await kvStore.deleteValue(key: key)
        let deletedValue = await kvStore.getValue(Bool.self, key: key)
        #expect(deletedValue == nil)
    }
    
    @Test
    func testGetSetDeleteStringValue() async {
        let key = "testStringKey"
        
        // Test getting the initial value (which should be nil).
        let initialValue = await kvStore.getValue(String.self, key: key)
        #expect(initialValue == nil)
        
        // Test setting a string value.
        let helloWorld = "Hello, World!"
        await kvStore.setValue(key: key, value: helloWorld)
        let secondValue = await kvStore.getValue(String.self, key: key)
        #expect(secondValue == helloWorld)
        
        // Test updating the string value.
        let helloSwift = "Hello, Swift!"
        await kvStore.setValue(key: key, value: helloSwift)
        let thirdValue = await kvStore.getValue(String.self, key: key)
        #expect(thirdValue == helloSwift)
        
        // Test deleting the value.
        await kvStore.deleteValue(key: key)
        let deletedValue = await kvStore.getValue(String.self, key: key)
        #expect(deletedValue == nil)
    }
    
    @Test
    func testGetSetDeleteIntValue() async {
        let key = "testIntKey"
        
        // Test getting the initial value (which should be nil).
        let initialValue = await kvStore.getValue(Int.self, key: key)
        #expect(initialValue == nil)
        
        // Test setting an integer value.
        let intValue = 10
        await kvStore.setValue(key: key, value: intValue)
        let secondValue = await kvStore.getValue(Int.self, key: key)
        #expect(secondValue == intValue)
        
        // Test updating the integer value.
        let updatedIntValue = 100
        await kvStore.setValue(key: key, value: updatedIntValue)
        let thirdValue = await kvStore.getValue(Int.self, key: key)
        #expect(thirdValue == updatedIntValue)
        
        // Test deleting the value.
        await kvStore.deleteValue(key: key)
        let deletedValue = await kvStore.getValue(Int.self, key: key)
        #expect(deletedValue == nil)
    }
    
    @Test
    func testGetSetDeleteJSONValue() async {
        struct TestStruct: Codable, Equatable {
            let statusCode: Int
            let message: String
        }
        
        let testObject = TestStruct(statusCode: 200, message: "Success")
        
        let key = "testJSONKey"
        // Test getting the initial value (which should be nil).
        let initialValue = await kvStore.getValue(TestStruct.self, key: key)
        #expect(initialValue == nil)
        
        // Test setting a JSON value.
        await kvStore.setValue(key: key, value: testObject)
        let secondValue = await kvStore.getValue(TestStruct.self, key: key)
        #expect(secondValue == testObject)
        
        // Test updating the JSON value.
        let updatedObject = TestStruct(statusCode: 404, message: "Not Found")
        await kvStore.setValue(key: key, value: updatedObject)
        let thirdValue = await kvStore.getValue(TestStruct.self, key: key)
        #expect(thirdValue == updatedObject)
        
        // Test deleting the value.
        await kvStore.deleteValue(key: key)
        let deletedValue = await kvStore.getValue(TestStruct.self, key: key)
        #expect(deletedValue == nil)
    }
    
    @Test
    func testSetAndClear() async {
        let boolKey = "testBoolKey"
        let stringKey = "testStringKey"
        
        // Set the values.
        await kvStore.setValue(key: boolKey, value: true)
        await kvStore.setValue(key: stringKey, value: "Hello, World!")
        
        // Test that the values are set correctly.
        let boolValue = await kvStore.getValue(Bool.self, key: boolKey)
        let stringValue = await kvStore.getValue(String.self, key: stringKey)
        #expect(boolValue == true)
        #expect(stringValue == "Hello, World!")
        
        // Clear the values.
        await kvStore.clear()
        // Test that the values are cleared.
        let clearedBoolValue = await kvStore.getValue(Bool.self, key: boolKey)
        let clearedStringValue = await kvStore.getValue(String.self, key: stringKey)
        #expect(clearedBoolValue == nil)
        #expect(clearedStringValue == nil)
    }
    
    @Test
    func testGetWithIncorrectType() async {
        let key = "testStringKey"
        let helloWorld = "Hello, World!"
        
        // Test setting a string value.
        await kvStore.setValue(key: key, value: helloWorld)
        
        // Test getting the value with an incorrect type.
        let incorrectValue = await kvStore.getValue(Int.self, key: key)
        #expect(incorrectValue == nil)
        
        // Test getting the value with the correct type.
        let correctValue = await kvStore.getValue(String.self, key: key)
        #expect(correctValue == helloWorld)
    }
    
    @Test
    func testGetValuesWithMultipleKeys() async {
        let keys = ["key1", "key2", "key3"]
        let values = ["Value 1", "Value 2", "Value 3"]
        
        // Set multiple values.
        for (index, key) in keys.enumerated() {
            await kvStore.setValue(key: key, value: values[index])
        }
        
        // Get values for multiple keys.
        let fetchedValues: [String]? = await kvStore.getValues(String.self, keys: keys)
        
        // Sort the values as the order might not be guaranteed.
        let sortedValues = fetchedValues?.sorted()
        
        #expect(sortedValues == values.sorted())
    }
    
}
