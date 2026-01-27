//
//  SwiftDataTableColumnSortabilityTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for the `isColumnSortable` configuration feature.
///
/// These tests verify:
/// - Default behavior where all columns are sortable
/// - Disabling sorting for specific columns via closure
/// - Sort indicator visibility for sortable vs non-sortable columns
/// - Default ordering interaction with non-sortable columns
/// - Edge cases like empty tables and single columns
@MainActor
class SwiftDataTableColumnSortabilityTests: XCTestCase {

    // MARK: - Test Helpers

    private func createDataTable(
        data: [[String]] = [["A", "B", "C"], ["D", "E", "F"]],
        headers: [String] = ["Col1", "Col2", "Col3"],
        isColumnSortable: ((Int) -> Bool)? = nil
    ) -> SwiftDataTable {
        var config = DataTableConfiguration()
        config.isColumnSortable = isColumnSortable
        return SwiftDataTable(data: data, headerTitles: headers, options: config, frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    }

    // MARK: - Default Behavior Tests

    func test_byDefault_allColumnsAreSortable() {
        let dataTable = createDataTable()

        // All columns should have non-hidden sort type
        for viewModel in dataTable.headerViewModels {
            XCTAssertNotEqual(viewModel.sortType, .hidden)
        }
    }

    func test_byDefault_isColumnSortable_isNil() {
        let dataTable = createDataTable()
        XCTAssertNil(dataTable.options.isColumnSortable)
    }

    // MARK: - Disabling Specific Column Tests

    func test_disablingColumn_setsSortTypeToHidden() {
        let dataTable = createDataTable(isColumnSortable: { $0 != 1 })

        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, .hidden)
        XCTAssertNotEqual(dataTable.headerViewModels[2].sortType, .hidden)
    }

    func test_disablingMultipleColumns_setsSortTypesToHidden() {
        let dataTable = createDataTable(isColumnSortable: { $0 == 1 })

        XCTAssertEqual(dataTable.headerViewModels[0].sortType, .hidden)
        XCTAssertNotEqual(dataTable.headerViewModels[1].sortType, .hidden)
        XCTAssertEqual(dataTable.headerViewModels[2].sortType, .hidden)
    }

    func test_disablingAllColumns_setsAllSortTypesToHidden() {
        let dataTable = createDataTable(isColumnSortable: { _ in false })

        for viewModel in dataTable.headerViewModels {
            XCTAssertEqual(viewModel.sortType, .hidden)
        }
    }

    // MARK: - Column Index Range Tests

    func test_sortableColumns_usingSetContains() {
        let sortableColumnIndices: Set<Int> = [0, 2]
        let dataTable = createDataTable(isColumnSortable: { sortableColumnIndices.contains($0) })

        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, .hidden)
        XCTAssertNotEqual(dataTable.headerViewModels[2].sortType, .hidden)
    }

    // MARK: - Header View Model Sort Type Tests

    func test_sortableColumn_hasUnspecifiedSortType() {
        let dataTable = createDataTable(isColumnSortable: { $0 == 0 })

        // Column 0 should be sortable with unspecified sort type
        XCTAssertEqual(dataTable.headerViewModels[0].sortType, .unspecified)
    }

    func test_nonSortableColumn_hasHiddenSortType() {
        let dataTable = createDataTable(isColumnSortable: { $0 == 0 })

        // Column 1 should not be sortable
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, .hidden)
    }

    // MARK: - Sort Indicator Image Tests

    func test_sortableColumn_hasImageString() {
        let dataTable = createDataTable(isColumnSortable: { $0 == 0 })

        XCTAssertNotNil(dataTable.headerViewModels[0].imageStringForSortingElement)
    }

    func test_nonSortableColumn_hasNilImageString() {
        let dataTable = createDataTable(isColumnSortable: { $0 == 0 })

        XCTAssertNil(dataTable.headerViewModels[1].imageStringForSortingElement)
    }

    // MARK: - Configuration Persistence Tests

    func test_isColumnSortable_persistsInConfiguration() {
        let closure: (Int) -> Bool = { $0 != 2 }
        let dataTable = createDataTable(isColumnSortable: closure)

        XCTAssertNotNil(dataTable.options.isColumnSortable)
        XCTAssertTrue(dataTable.options.isColumnSortable?(0) ?? false)
        XCTAssertTrue(dataTable.options.isColumnSortable?(1) ?? false)
        XCTAssertFalse(dataTable.options.isColumnSortable?(2) ?? true)
    }

    // MARK: - Edge Case Tests

    func test_emptyDataTable_withIsColumnSortable_doesNotCrash() {
        let dataTable = createDataTable(
            data: [],
            headers: ["A", "B", "C"],
            isColumnSortable: { $0 != 1 }
        )

        XCTAssertNotNil(dataTable)
        XCTAssertEqual(dataTable.headerViewModels.count, 3)
    }

    func test_singleColumn_canBeDisabled() {
        let dataTable = createDataTable(
            data: [["X"]],
            headers: ["Single"],
            isColumnSortable: { _ in false }
        )

        XCTAssertEqual(dataTable.headerViewModels[0].sortType, .hidden)
    }

    func test_singleColumn_canBeEnabled() {
        let dataTable = createDataTable(
            data: [["X"]],
            headers: ["Single"],
            isColumnSortable: { _ in true }
        )

        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)
    }

    // MARK: - Default Ordering with Non-Sortable Column Tests

    func test_defaultOrdering_onNonSortableColumn_isIgnored() {
        var config = DataTableConfiguration()
        config.isColumnSortable = { $0 != 1 }
        config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)

        let dataTable = SwiftDataTable(
            data: [["A", "B", "C"]],
            headerTitles: ["Col1", "Col2", "Col3"],
            options: config,
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Column 1 should still have hidden sort type even with default ordering
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, .hidden)
    }

    func test_defaultOrdering_onSortableColumn_isApplied() {
        var config = DataTableConfiguration()
        config.isColumnSortable = { $0 != 2 }
        config.defaultOrdering = DataTableColumnOrder(index: 0, order: .ascending)

        let dataTable = SwiftDataTable(
            data: [["A", "B", "C"]],
            headerTitles: ["Col1", "Col2", "Col3"],
            options: config,
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Column 0 should have ascending sort type
        XCTAssertEqual(dataTable.headerViewModels[0].sortType, .ascending)
    }
}
