//
//  SwiftDataTableTypedAPITests.swift
//  SwiftDataTablesTests
//
//  Tests for SwiftDataTable typed API including initialization,
//  setData with diffing, and model access.
//

import XCTest
@testable import SwiftDataTables

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

    func test_typedInit_createsTableWithCorrectHeaders() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        let headers = table.headerViewModels

        XCTAssertEqual(headers.count, 3)
        XCTAssertEqual(headers[0].data, "Name")
        XCTAssertEqual(headers[1].data, "Age")
        XCTAssertEqual(headers[2].data, "Score")
    }

    func test_typedInit_createsTableWithCorrectRowCount() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        XCTAssertEqual(table.rows.count, 3)
    }

    func test_typedInit_extractsValuesCorrectly() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        // Check first row values
        let firstRow = table.rows[0]
        XCTAssertEqual(firstRow[0].data.stringRepresentation, "Alice")
        XCTAssertEqual(firstRow[1].data.stringRepresentation, "30")
        XCTAssertEqual(firstRow[2].data.stringRepresentation, "95.5")
    }

    func test_typedInit_withEmptyData_createsEmptyTable() {
        let emptyUsers: [User] = []
        let table = SwiftDataTable(data: emptyUsers, columns: columns)

        XCTAssertEqual(table.rows.count, 0)
    }

    func test_typedInit_withConfiguration_appliesOptions() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: sampleUsers, columns: columns, options: config)

        XCTAssertFalse(table.options.shouldShowSearchSection)
    }

    // MARK: - Typed setData Diffing Tests

    func test_typedSetData_appendsNewRows() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Append new user
        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 4)
        XCTAssertEqual(table.rows[3][0].data.stringRepresentation, "Diana")
    }

    func test_typedSetData_deletesRows() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Remove Bob (id: 2)
        users.removeAll { $0.id == 2 }
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 2)
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice", "Charlie"])
    }

    func test_typedSetData_updatesRowContent() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Update Bob's name (keeping same id)
        users[1] = User(id: 2, name: "Robert", age: 26, score: 89.0)
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 3)
        XCTAssertEqual(table.rows[1][0].data.stringRepresentation, "Robert")
        XCTAssertEqual(table.rows[1][1].data.stringRepresentation, "26")
    }

    func test_typedSetData_handlesMixedOperations() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Remove first, add at end, update middle
        users.removeFirst()
        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        users[0] = User(id: 2, name: "Robert", age: 26, score: 89.0)
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 3)
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Robert", "Charlie", "Diana"])
    }

    func test_typedSetData_clearsAllRows() {
        let users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Clear all
        table.setData([User](), animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 0)
    }

    func test_typedSetData_reordersRows() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Reverse order
        users.reverse()
        table.setData(users, animatingDifferences: false)

        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Charlie", "Bob", "Alice"])
    }

    func test_typedSetData_usesIdentifiableId_forDiffing() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Same IDs, different content - should update in place
        users = [
            User(id: 1, name: "Alice Updated", age: 31, score: 96.0),
            User(id: 2, name: "Bob Updated", age: 26, score: 89.0),
            User(id: 3, name: "Charlie Updated", age: 36, score: 93.0)
        ]
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 3)
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice Updated", "Bob Updated", "Charlie Updated"])
    }

    // MARK: - Model Access Tests

    func test_modelAtRow_returnsCorrectModel() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        let user: User? = table.model(at: 1)

        XCTAssertNotNil(user)
        XCTAssertEqual(user?.name, "Bob")
        XCTAssertEqual(user?.id, 2)
    }

    func test_modelAtRow_withInvalidIndex_returnsNil() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        let user: User? = table.model(at: 100)

        XCTAssertNil(user)
    }

    func test_modelAtRow_withNegativeIndex_returnsNil() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        let user: User? = table.model(at: -1)

        XCTAssertNil(user)
    }

    func test_allModels_returnsAllStoredModels() {
        let table = SwiftDataTable(data: sampleUsers, columns: columns)

        let users: [User]? = table.allModels()

        XCTAssertNotNil(users)
        XCTAssertEqual(users?.count, 3)
        XCTAssertEqual(users?[0].name, "Alice")
        XCTAssertEqual(users?[1].name, "Bob")
        XCTAssertEqual(users?[2].name, "Charlie")
    }

    func test_allModels_afterSetData_returnsUpdatedModels() {
        var users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        users.append(User(id: 4, name: "Diana", age: 28, score: 91.0))
        table.setData(users, animatingDifferences: false)

        let storedUsers: [User]? = table.allModels()

        XCTAssertEqual(storedUsers?.count, 4)
        XCTAssertEqual(storedUsers?.last?.name, "Diana")
    }

    // MARK: - Custom Column Extraction Tests

    func test_typedInit_withCustomExtract_usesCustomClosure() {
        let customColumns: [DataTableColumn<User>] = [
            .init("Full Info") { user in
                .string("\(user.name) - Age: \(user.age)")
            }
        ]
        let users = [User(id: 1, name: "Test", age: 25, score: 80.0)]

        let table = SwiftDataTable(data: users, columns: customColumns)

        XCTAssertEqual(table.rows[0][0].data.stringRepresentation, "Test - Age: 25")
    }

    func test_typedInit_withHeaderOnlyColumn_usesEmptyString() {
        let mixedColumns: [DataTableColumn<User>] = [
            .init("Name", \.name),
            .init("Actions")  // Header-only for custom cell
        ]
        let users = [User(id: 1, name: "Test", age: 25, score: 80.0)]

        let table = SwiftDataTable(data: users, columns: mixedColumns)

        XCTAssertEqual(table.rows[0][0].data.stringRepresentation, "Test")
        XCTAssertEqual(table.rows[0][1].data.stringRepresentation, "")
    }

    // MARK: - Edge Cases

    func test_typedSetData_withSameData_maintainsState() {
        let users = sampleUsers
        let table = SwiftDataTable(data: users, columns: columns)

        // Set same data again
        table.setData(users, animatingDifferences: false)

        XCTAssertEqual(table.rows.count, 3)
        let names = table.rows.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Alice", "Bob", "Charlie"])
    }

    // Note: Changing columns after initialization (to a different column count)
    // is not supported. The setData method is intended for updating row data
    // while keeping the same column structure. To change columns, create a new
    // SwiftDataTable instance.
}
