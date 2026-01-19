//
//  SwiftDataTableIncrementalUpdatesTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableIncrementalUpdatesTests: XCTestCase {

    func test_setData_appendsNewRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Append a new row
        data.append([.string("C")])
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "B", "C"])
    }

    func test_setData_insertsRowAtPosition() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Insert in the middle
        data.insert([.string("B")], at: 1)
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "B", "C"])
    }

    func test_setData_deletesRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")],
            [.string("D")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Remove rows at indices 1 and 3 (B and D)
        data.remove(at: 3)
        data.remove(at: 1)
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "C"])
    }

    func test_setData_updatesRowContent() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Update row at index 1
        data[1] = [.string("Z")]
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "Z", "C"])
    }

    func test_setData_handlesMixedOperations() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Delete first row, insert new row at end
        data.remove(at: 0)
        data.append([.string("D")])
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["B", "C", "D"])
    }

    func test_setData_clearsAllRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Clear all
        data.removeAll()
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), [])
    }

    func test_setData_withExplicitIdentifiers_tracksCorrectly() {
        var data: DataTableContent = [
            [.string("Alice")],
            [.string("Bob")]
        ]
        var identifiers = ["id1", "id2"]
        let table = SwiftDataTable(data: data, headerTitles: ["Name"])

        // Initial setup
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // Add a new row with its own ID
        data.append([.string("Charlie")])
        identifiers.append("id3")
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["Alice", "Bob", "Charlie"])

        // Update Bob's content (same ID, different content)
        data[1] = [.string("Robert")]
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // With ID-based tracking, Robert replaces Bob at the same position
        XCTAssertEqual(rowStrings(in: table), ["Alice", "Robert", "Charlie"])
    }
}

@MainActor
private func rowStrings(in table: SwiftDataTable) -> [String] {
    return table.rows.compactMap { $0.first?.data.stringRepresentation }
}
