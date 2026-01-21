//
//  SwiftDataTableColumnWidthLockTests.swift
//  SwiftDataTablesTests
//
//  Phase 2 tests: Column width decoupling and lock functionality.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableColumnWidthLockTests: XCTestCase {

    // MARK: - Default Behavior Tests

    func test_default_lockColumnWidthsAfterFirstLayout_isFalse() {
        let config = DataTableConfiguration()
        XCTAssertFalse(config.lockColumnWidthsAfterFirstLayout)
    }

    // MARK: - Width Lock Tests

    func test_columnWidths_recalculatedByDefault_whenDataChanges() {
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = false
        options.columnWidthMode = .fitContentText(strategy: .estimatedAverage(averageCharWidth: 10))
        options.shouldContentWidthScaleToFillFrame = false  // Disable scaling to see actual content width changes

        // Initial data with short text
        let shortData: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: shortData, headerTitles: ["Header"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        let initialWidth = table.widthForColumn(index: 0)

        // Update with longer text
        let longData: DataTableContent = [[.string("Very Long Text Here")], [.string("More Long Text")]]
        table.setData(longData)

        let updatedWidth = table.widthForColumn(index: 0)

        // Width should change because data content is longer
        XCTAssertNotEqual(initialWidth, updatedWidth, "Width should change when lock is disabled and content changes")
    }

    func test_columnWidths_locked_afterFirstLayout() {
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = true
        options.columnWidthMode = .fitContentText(strategy: .estimatedAverage(averageCharWidth: 10))
        options.shouldContentWidthScaleToFillFrame = false

        // Initial data with short text
        let shortData: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: shortData, headerTitles: ["Header"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        let initialWidth = table.widthForColumn(index: 0)

        // Update with longer text
        let longData: DataTableContent = [[.string("Very Long Text Here")], [.string("More Long Text")]]
        table.setData(longData)

        let lockedWidth = table.widthForColumn(index: 0)

        // Width should NOT change because lock is enabled
        XCTAssertEqual(initialWidth, lockedWidth, "Width should remain locked after first layout")
    }

    func test_columnWidths_lockPreventsWidthDrift_acrossMultipleUpdates() {
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = true
        options.columnWidthMode = .fitContentText(strategy: .estimatedAverage(averageCharWidth: 10))
        options.shouldContentWidthScaleToFillFrame = false

        let initialData: DataTableContent = [[.string("Medium")]]
        let table = SwiftDataTable(data: initialData, headerTitles: ["Col"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        let initialWidth = table.widthForColumn(index: 0)

        // Multiple updates with varying content lengths
        table.setData([[.string("X")]])
        let width1 = table.widthForColumn(index: 0)

        table.setData([[.string("Very Very Long String")]])
        let width2 = table.widthForColumn(index: 0)

        table.setData([[.string("Short")]])
        let width3 = table.widthForColumn(index: 0)

        // All widths should match initial
        XCTAssertEqual(initialWidth, width1, "Width should stay locked (update 1)")
        XCTAssertEqual(initialWidth, width2, "Width should stay locked (update 2)")
        XCTAssertEqual(initialWidth, width3, "Width should stay locked (update 3)")
    }

    // MARK: - Equatable Tests

    func test_configuration_equatable_includeslockColumnWidthsAfterFirstLayout() {
        var config1 = DataTableConfiguration()
        var config2 = DataTableConfiguration()

        config1.lockColumnWidthsAfterFirstLayout = false
        config2.lockColumnWidthsAfterFirstLayout = false
        XCTAssertEqual(config1, config2)

        config2.lockColumnWidthsAfterFirstLayout = true
        XCTAssertNotEqual(config1, config2, "Configurations should differ when lockColumnWidthsAfterFirstLayout differs")
    }

    // MARK: - Height Rebuild Tests

    func test_rowHeights_stillRebuilt_whenWidthsLocked() {
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = true
        options.rowHeightMode = .fixed(44)

        let data1: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data1, headerTitles: ["H"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)

        // Update with more rows
        let data2: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        table.setData(data2)

        // Row count should update even though widths are locked
        XCTAssertEqual(table.rowMetricsStore.rowCount, 4, "Row metrics should be rebuilt even when widths are locked")
    }

}
