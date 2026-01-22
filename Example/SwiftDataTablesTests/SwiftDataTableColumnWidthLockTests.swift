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

    // MARK: - Config Change Bypass Tests

    func test_columnWidths_recalculated_whenColumnWidthModeChanges_despiteLock() {
        // Lock must be bypassed when columnWidthMode config changes
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = true
        options.columnWidthMode = .fixed(width: 150)
        options.shouldContentWidthScaleToFillFrame = false

        let data: DataTableContent = [[.string("Test")]]
        let table = SwiftDataTable(data: data, headerTitles: ["Header"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        let initialWidth = table.widthForColumn(index: 0)

        // Change columnWidthMode config - this should bypass the lock
        table.options.columnWidthMode = .fixed(width: 250)
        table.calculateColumnWidths()

        let updatedWidth = table.widthForColumn(index: 0)

        // Width should change when columnWidthMode changes, even with lock enabled
        XCTAssertNotEqual(initialWidth, updatedWidth, "Width should recalculate when columnWidthMode changes, despite lock")
        XCTAssertEqual(updatedWidth, 250, "Width should reflect new fixed width")
    }

    func test_columnWidths_recalculated_whenProviderVersionChanges_despiteLock() {
        // Lock must be bypassed when columnWidthModeProviderVersion changes
        var options = DataTableConfiguration()
        options.lockColumnWidthsAfterFirstLayout = true
        options.shouldContentWidthScaleToFillFrame = false

        // Start with provider returning fixed 150
        options.columnWidthModeProvider = { _ in .fixed(width: 150) }
        options.columnWidthModeProviderVersion = 1

        let data: DataTableContent = [[.string("Test")]]
        let table = SwiftDataTable(data: data, headerTitles: ["Header"], options: options)
        table.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        table.calculateColumnWidths()

        let initialWidth = table.widthForColumn(index: 0)
        XCTAssertEqual(initialWidth, 150, "Initial width should be 150 from provider")

        // Change provider to return 250, increment version to signal the change
        table.options.columnWidthModeProvider = { _ in .fixed(width: 250) }
        table.options.columnWidthModeProviderVersion = 2
        table.calculateColumnWidths()

        let updatedWidth = table.widthForColumn(index: 0)

        // Width should change when provider version changes, even with lock enabled
        XCTAssertNotEqual(initialWidth, updatedWidth, "Width should recalculate when providerVersion changes, despite lock")
        XCTAssertEqual(updatedWidth, 250, "Width should reflect new provider's fixed width")
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
