//
//  DataTableSortTypeTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
@testable import SwiftDataTables

class DataTableSortTypeTests: XCTestCase {

    // MARK: - Raw Value Tests

    func test_rawValue_hidden() {
        XCTAssertEqual(DataTableSortType.hidden.rawValue, "hidden")
    }

    func test_rawValue_unspecified() {
        XCTAssertEqual(DataTableSortType.unspecified.rawValue, "unspecified")
    }

    func test_rawValue_ascending() {
        XCTAssertEqual(DataTableSortType.ascending.rawValue, "ascending")
    }

    func test_rawValue_descending() {
        XCTAssertEqual(DataTableSortType.descending.rawValue, "descending")
    }

    // MARK: - Toggle Tests (Critical for Sort Cycling)

    func test_toggle_fromUnspecified_goesToAscending() {
        var sortType = DataTableSortType.unspecified
        sortType.toggle()
        XCTAssertEqual(sortType, .ascending)
    }

    func test_toggle_fromAscending_goesToDescending() {
        var sortType = DataTableSortType.ascending
        sortType.toggle()
        XCTAssertEqual(sortType, .descending)
    }

    func test_toggle_fromDescending_goesToAscending() {
        var sortType = DataTableSortType.descending
        sortType.toggle()
        XCTAssertEqual(sortType, .ascending)
    }

    func test_toggle_fromHidden_staysHidden() {
        var sortType = DataTableSortType.hidden
        sortType.toggle()
        XCTAssertEqual(sortType, .hidden)
    }

    func test_toggle_multipleTimes_cyclesCorrectly() {
        var sortType = DataTableSortType.unspecified

        sortType.toggle() // unspecified -> ascending
        XCTAssertEqual(sortType, .ascending)

        sortType.toggle() // ascending -> descending
        XCTAssertEqual(sortType, .descending)

        sortType.toggle() // descending -> ascending
        XCTAssertEqual(sortType, .ascending)

        sortType.toggle() // ascending -> descending
        XCTAssertEqual(sortType, .descending)
    }

    // MARK: - Toggle to Default Tests

    func test_toggleToDefault_fromAscending_goesToUnspecified() {
        var sortType = DataTableSortType.ascending
        sortType.toggleToDefault()
        XCTAssertEqual(sortType, .unspecified)
    }

    func test_toggleToDefault_fromDescending_goesToUnspecified() {
        var sortType = DataTableSortType.descending
        sortType.toggleToDefault()
        XCTAssertEqual(sortType, .unspecified)
    }

    func test_toggleToDefault_fromUnspecified_staysUnspecified() {
        var sortType = DataTableSortType.unspecified
        sortType.toggleToDefault()
        XCTAssertEqual(sortType, .unspecified)
    }

    func test_toggleToDefault_fromHidden_staysHidden() {
        var sortType = DataTableSortType.hidden
        sortType.toggleToDefault()
        XCTAssertEqual(sortType, .hidden)
    }

    // MARK: - Equality Tests

    func test_equality_sameSortTypes_areEqual() {
        XCTAssertEqual(DataTableSortType.ascending, DataTableSortType.ascending)
        XCTAssertEqual(DataTableSortType.descending, DataTableSortType.descending)
        XCTAssertEqual(DataTableSortType.hidden, DataTableSortType.hidden)
        XCTAssertEqual(DataTableSortType.unspecified, DataTableSortType.unspecified)
    }

    func test_equality_differentSortTypes_areNotEqual() {
        XCTAssertNotEqual(DataTableSortType.ascending, DataTableSortType.descending)
        XCTAssertNotEqual(DataTableSortType.hidden, DataTableSortType.unspecified)
    }

    // MARK: - Column Sorting Simulation

    func test_columnSortCycle_simulatesHeaderTaps() {
        // Simulates what happens when user taps a column header multiple times
        var columnSortStates: [DataTableSortType] = [.unspecified, .unspecified, .unspecified]
        let tappedColumn = 1

        // First tap on column 1
        columnSortStates[tappedColumn].toggle()
        for i in 0..<columnSortStates.count where i != tappedColumn {
            columnSortStates[i].toggleToDefault()
        }

        XCTAssertEqual(columnSortStates[0], .unspecified)
        XCTAssertEqual(columnSortStates[1], .ascending)
        XCTAssertEqual(columnSortStates[2], .unspecified)

        // Second tap on column 1
        columnSortStates[tappedColumn].toggle()
        for i in 0..<columnSortStates.count where i != tappedColumn {
            columnSortStates[i].toggleToDefault()
        }

        XCTAssertEqual(columnSortStates[0], .unspecified)
        XCTAssertEqual(columnSortStates[1], .descending)
        XCTAssertEqual(columnSortStates[2], .unspecified)
    }

    func test_switchingColumns_resetsPreviousColumn() {
        var columnSortStates: [DataTableSortType] = [.unspecified, .unspecified, .unspecified]

        // Tap column 0
        columnSortStates[0].toggle()
        XCTAssertEqual(columnSortStates[0], .ascending)

        // Tap column 2
        columnSortStates[2].toggle()
        columnSortStates[0].toggleToDefault()
        columnSortStates[1].toggleToDefault()

        XCTAssertEqual(columnSortStates[0], .unspecified) // Reset
        XCTAssertEqual(columnSortStates[1], .unspecified)
        XCTAssertEqual(columnSortStates[2], .ascending) // New active column
    }
}
