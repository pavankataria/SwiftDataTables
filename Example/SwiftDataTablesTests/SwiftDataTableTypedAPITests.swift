//
//  SwiftDataTableTypedAPITests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
@testable import SwiftDataTables

/// Tests for SwiftDataTable's type-safe API.
///
/// This test class validates the typed API that allows working directly with
/// model types instead of raw `[[DataTableValueType]]` arrays. It covers:
///
/// ## Test Coverage
///
/// - **Initialization**: Creating tables with typed data and column definitions
/// - **Data Updates**: Using `setData` with automatic diffing
/// - **Model Access**: Retrieving typed models from the table
/// - **Custom Columns**: Using custom extraction closures and header-only columns
/// - **Edge Cases**: Empty data, same data updates, type safety
///
/// ## Test Model
///
/// Tests use a simple `User` struct with `Identifiable` conformance:
/// ```swift
/// struct User: Identifiable {
///     let id: Int
///     let name: String
///     let age: Int
///     let score: Double
/// }
/// ```
@MainActor
final class SwiftDataTableTypedAPITests: XCTestCase {

    // MARK: - Test Model

    private struct User: Identifiable, Equatable {
        let id: Int
        let name: String
        let age: Int
        let score: Double
    }

    private var sampleUsers: [User] {
        [
            User(id: 1, name: "Alice", age: 30, score: 95.5),
            User(id: 2, name: "Bob", age: 25, score: 88.0),
            User(id: 3, name: "Charlie", age: 35, score: 92.5)
        ]
    }

    private var columns: [DataTableColumn<User>] {
        [
            .init("Name", \.name),
            .init("Age", \.age),
            .init("Score", \.score)
        ]
    }

    // MARK: - Initialization Tests

    /// Verifies that column headers are correctly extracted from column definitions.
    ///
    /// ## Given
    /// - Sample users array with 3 users
    /// - Column definitions for Name, Age, and Score
    ///
    /// ## When
    /// - A SwiftDataTable is initialized with typed data and columns
    ///
    /// ## Then
    /// - The table should have exactly 3 header view models
    /// - Headers should be "Name", "Age", "Score" in order
    func test_typedInit_createsTableWithCorrectHeaders() {
        // Given
        let users = sampleUsers

        // When
        let table = SwiftDataTable(data: users, columns: columns)

        // Then
        let headers = table.headerViewModels
        XCTAssertEqual(headers.count, 3, "Should have 3 columns")
        XCTAssertEqual(headers[0].data, "Name", "First column should be 'Name'")
        XCTAssertEqual(headers[1].data, "Age", "Second column should be 'Age'")
        XCTAssertEqual(headers[2].data, "Score", "Third column should be 'Score'")
    }

    /// Verifies that the table creates the correct number of rows.
    ///
    /// ## Given
    /// - Sample users array with 3 users
    ///
    /// ## When
    /// - A SwiftDataTable is initialized with the typed data
    ///
    /// ## Then
    /// - The table should have exactly 3 rows
    func test_typedInit_createsTableWithCorrectRowCount() {
        // Given
        let users = sampleUsers

        // When
        let table = SwiftDataTable(data: users, columns: columns)

        // Then
        XCTAssertEqual(table.rows.count, 3, "Should have 3 rows matching the 3 users")
    }

    /// Verifies that property values are correctly extracted into cell values.
    ///
    /// ## Given
    /// - Sample users with known values (Alice, age 30, score 95.5)
    ///
    /// ## When
    /// - A SwiftDataTable is initialized with the typed data
    ///
    /// ## Then
    /// - First row should contain "Alice", "30", "95.5" as string representations
    func test_typedInit_extractsValuesCorrectly() {
        // Given
        let users = sampleUsers

        // When
        let table = SwiftDataTable(data: users, columns: columns)

        // Then
        let firstRow = table.rows[0]
        XCTAssertEqual(firstRow[0].data.stringRepresentation, "Alice", "Name should be 'Alice'")
        XCTAssertEqual(firstRow[1].data.stringRepresentation, "30", "Age should be '30'")
        XCTAssertEqual(firstRow[2].data.stringRepresentation, "95.5", "Score should be '95.5'")
    }

    /// Verifies that initializing with empty data creates an empty table.
    ///
    /// ## Given
    /// - An empty users array
    ///
    /// ## When
    /// - A SwiftDataTable is initialized with the empty array
    ///
    /// ## Then
    /// - The table should have 0 rows
    func test_typedInit_withEmptyData_createsEmptyTable() {
        // Given
        let emptyUsers: [User] = []

        // When
        let table = SwiftDataTable(data: emptyUsers, columns: columns)

        // Then
        XCTAssertEqual(table.rows.count, 0, "Empty data should create empty table")
    }

    /// Verifies that configuration options are correctly applied.
    ///
    /// ## Given
    /// - A configuration with search section disabled
    ///
    /// ## When
    /// - A SwiftDataTable is initialized with that configuration
    ///
    /// ## Then
    /// - The table's options should have shouldShowSearchSection as false
    func test_typedInit_withConfiguration_appliesOptions() {
        // Given
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        // When
        let table = SwiftDataTable(data: sampleUsers, columns: columns, options: config)

        // Then
        XCTAssertFalse(table.options.shouldShowSearchSection,
                       "Configuration option should be applied")
    }

    // MARK: - Typed setData Diffing Tests

    /// Verifies that new rows are appended correctly.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    /// - A new user "Diana" to append
    ///
    /// ## When
    /// - setData is called with 4 users (original 3 + Diana)
    ///
    /// ## Then
    /// - Table should have 4 rows
    /// - Last row should contain "Diana"
    func test_typedSetData_appendsNewRows() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 4, "Should have 4 rows after append")
        XCTAssertEqual(table.rows[3][0].data.stringRepresentation, "Diana",
                       "Last row should be 'Diana'")
    }

    /// Verifies that rows are correctly deleted.
    ///
    /// ## Given
    /// - A table initialized with 3 users (Alice, Bob, Charlie)
    ///
    /// ## When
    /// - setData is called with Bob removed
    ///
    /// ## Then
    /// - Table should have 2 rows
    /// - Remaining rows should be Alice and Charlie
    func test_typedSetData_deletesRows() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users.removeAll { $0.id == 2 }
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 2, "Should have 2 rows after deletion")
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice", "Charlie"], "Bob should be removed")
    }

    /// Verifies that row content updates are detected and applied.
    ///
    /// ## Given
    /// - A table initialized with Bob (id: 2, name: "Bob", age: 25)
    ///
    /// ## When
    /// - setData is called with Bob's name changed to "Robert" and age to 26
    ///
    /// ## Then
    /// - Table should still have 3 rows
    /// - Second row should show "Robert" and "26"
    func test_typedSetData_updatesRowContent() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users[1] = User(id: 2, name: "Robert", age: 26, score: 89.0)
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 3, "Row count should remain 3")
        XCTAssertEqual(table.rows[1][0].data.stringRepresentation, "Robert",
                       "Name should be updated to 'Robert'")
        XCTAssertEqual(table.rows[1][1].data.stringRepresentation, "26",
                       "Age should be updated to '26'")
    }

    /// Verifies that mixed operations (add, remove, update) are handled correctly.
    ///
    /// ## Given
    /// - A table initialized with Alice, Bob, Charlie
    ///
    /// ## When
    /// - Alice is removed
    /// - Diana is added
    /// - Bob is renamed to Robert
    ///
    /// ## Then
    /// - Table should have 3 rows
    /// - Names should be Robert, Charlie, Diana
    func test_typedSetData_handlesMixedOperations() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users.removeFirst()
        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        users[0] = User(id: 2, name: "Robert", age: 26, score: 89.0)
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 3, "Should have 3 rows after mixed operations")
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Robert", "Charlie", "Diana"],
                       "Names should reflect all changes")
    }

    /// Verifies that all rows can be cleared.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    ///
    /// ## When
    /// - setData is called with an empty array
    ///
    /// ## Then
    /// - Table should have 0 rows
    func test_typedSetData_clearsAllRows() {
        // Given
        let users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        table.setData([User](), animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 0, "Table should be empty after clearing")
    }

    /// Verifies that row reordering is correctly detected and applied.
    ///
    /// ## Given
    /// - A table initialized with Alice, Bob, Charlie
    ///
    /// ## When
    /// - setData is called with reversed order
    ///
    /// ## Then
    /// - Names should be Charlie, Bob, Alice
    func test_typedSetData_reordersRows() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users.reverse()
        table.setData(users, animatingDifferences: false)

        // Then
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Charlie", "Bob", "Alice"],
                       "Rows should be in reverse order")
    }

    /// Verifies that diffing uses Identifiable.id for tracking.
    ///
    /// ## Given
    /// - A table initialized with Alice, Bob, Charlie
    ///
    /// ## When
    /// - setData is called with same IDs but updated content
    ///
    /// ## Then
    /// - Row count should remain 3
    /// - All names should show "Updated" suffix
    func test_typedSetData_usesIdentifiableId_forDiffing() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users = [
            User(id: 1, name: "Alice Updated", age: 31, score: 96.0),
            User(id: 2, name: "Bob Updated", age: 26, score: 89.0),
            User(id: 3, name: "Charlie Updated", age: 36, score: 93.0)
        ]
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 3, "Row count should remain 3")
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice Updated", "Bob Updated", "Charlie Updated"],
                       "All rows should be updated in place")
    }

    // MARK: - Model Access Tests

    /// Verifies that the correct model is returned for a valid row index.
    ///
    /// ## Given
    /// - A table initialized with Alice, Bob, Charlie
    ///
    /// ## When
    /// - model(at: 1) is called
    ///
    /// ## Then
    /// - Should return Bob (id: 2, name: "Bob")
    func test_modelAtRow_returnsCorrectModel() {
        // Given
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        // When
        let user: User? = table.model(at: 1)

        // Then
        XCTAssertNotNil(user, "Should return a model")
        XCTAssertEqual(user?.name, "Bob", "Should be Bob")
        XCTAssertEqual(user?.id, 2, "Should have id 2")
    }

    /// Verifies that nil is returned for out-of-bounds index.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    ///
    /// ## When
    /// - model(at: 100) is called
    ///
    /// ## Then
    /// - Should return nil
    func test_modelAtRow_withInvalidIndex_returnsNil() {
        // Given
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        // When
        let user: User? = table.model(at: 100)

        // Then
        XCTAssertNil(user, "Out-of-bounds index should return nil")
    }

    /// Verifies that nil is returned for negative index.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    ///
    /// ## When
    /// - model(at: -1) is called
    ///
    /// ## Then
    /// - Should return nil
    func test_modelAtRow_withNegativeIndex_returnsNil() {
        // Given
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        // When
        let user: User? = table.model(at: -1)

        // Then
        XCTAssertNil(user, "Negative index should return nil")
    }

    /// Verifies that all stored models can be retrieved.
    ///
    /// ## Given
    /// - A table initialized with Alice, Bob, Charlie
    ///
    /// ## When
    /// - allModels() is called
    ///
    /// ## Then
    /// - Should return array of 3 users
    /// - Users should be in original order
    func test_allModels_returnsAllStoredModels() {
        // Given
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        // When
        let users: [User]? = table.allModels()

        // Then
        XCTAssertNotNil(users, "Should return models")
        XCTAssertEqual(users?.count, 3, "Should have 3 models")
        XCTAssertEqual(users?[0].name, "Alice", "First should be Alice")
        XCTAssertEqual(users?[1].name, "Bob", "Second should be Bob")
        XCTAssertEqual(users?[2].name, "Charlie", "Third should be Charlie")
    }

    /// Verifies that allModels reflects data updates.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    /// - A new user Diana added via setData
    ///
    /// ## When
    /// - allModels() is called
    ///
    /// ## Then
    /// - Should return 4 users
    /// - Last user should be Diana
    func test_allModels_afterSetData_returnsUpdatedModels() {
        // Given
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        table.setData(users, animatingDifferences: false)
        let storedUsers: [User]? = table.allModels()

        // Then
        XCTAssertEqual(storedUsers?.count, 4, "Should have 4 users after update")
        XCTAssertEqual(storedUsers?.last?.name, "Diana", "Last should be Diana")
    }

    // MARK: - Custom Column Extraction Tests

    /// Verifies that custom extraction closures work correctly.
    ///
    /// ## Given
    /// - A column with custom extraction that formats name and age
    ///
    /// ## When
    /// - A table is initialized with that column
    ///
    /// ## Then
    /// - Cell should contain the formatted string "Test - Age: 25"
    func test_typedInit_withCustomExtract_usesCustomClosure() {
        // Given
        let customColumns: [DataTableColumn<User>] = [
            .init("Full Info") { user in
                .string("\(user.name) - Age: \(user.age)")
            }
        ]
        let users = [User(id: 1, name: "Test", age: 25, score: 80.0)]

        // When
        let table = SwiftDataTable(data: users, columns: customColumns)

        // Then
        XCTAssertEqual(table.rows[0][0].data.stringRepresentation, "Test - Age: 25",
                       "Custom extraction should format the value")
    }

    /// Verifies that header-only columns produce empty string values.
    ///
    /// ## Given
    /// - Columns with one KeyPath column and one header-only column
    ///
    /// ## When
    /// - A table is initialized with those columns
    ///
    /// ## Then
    /// - First column should have the value
    /// - Second column (header-only) should have empty string
    func test_typedInit_withHeaderOnlyColumn_usesEmptyString() {
        // Given
        let mixedColumns: [DataTableColumn<User>] = [
            .init("Name", \.name),
            .init("Actions")  // Header-only for custom cell
        ]
        let users = [User(id: 1, name: "Test", age: 25, score: 80.0)]

        // When
        let table = SwiftDataTable(data: users, columns: mixedColumns)

        // Then
        XCTAssertEqual(table.rows[0][0].data.stringRepresentation, "Test",
                       "Name column should have value")
        XCTAssertEqual(table.rows[0][1].data.stringRepresentation, "",
                       "Header-only column should have empty string")
    }

    // MARK: - Edge Cases

    /// Verifies that setting the same data doesn't corrupt state.
    ///
    /// ## Given
    /// - A table initialized with 3 users
    ///
    /// ## When
    /// - setData is called with the exact same data
    ///
    /// ## Then
    /// - Table should still have 3 rows
    /// - Names should be unchanged
    func test_typedSetData_withSameData_maintainsState() {
        // Given
        let users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // When
        table.setData(users, animatingDifferences: false)

        // Then
        XCTAssertEqual(table.rows.count, 3, "Row count should remain 3")
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice", "Bob", "Charlie"],
                       "Names should be unchanged")
    }
}
