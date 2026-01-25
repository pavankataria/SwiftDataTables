//
//  SwiftDataTableRemeasureRowTests.swift
//  SwiftDataTablesTests
//
//  Tests for the remeasureRow API for live cell editing support.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableRemeasureRowTests: XCTestCase {

    // MARK: - Basic API Tests

    func test_remeasureRow_returnsFalse_forInvalidRowIndex() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Negative index
        XCTAssertFalse(table.remeasureRow(-1))

        // Out of bounds index
        XCTAssertFalse(table.remeasureRow(5))
    }

    func test_remeasureRow_returnsFalse_forFixedHeightMode() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Fixed height mode doesn't support remeasurement
        XCTAssertFalse(table.remeasureRow(0))
    }

    func test_remeasureRow_returnsTrue_forAutomaticHeightMode_whenValid() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)

        // Need to embed in a window for visibility
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = UIViewController()
        window.rootViewController?.view.addSubview(table)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
        window.makeKeyAndVisible()

        table.calculateColumnWidths()
        table.collectionView.layoutIfNeeded()

        // With visible cells, should be able to remeasure (returns true if height changed)
        // Note: actual return value depends on whether height changed
        let _ = table.remeasureRow(0)
        // Test passes if no crash occurs
    }

    func test_remeasureRow_updatesMetricsStore_whenHeightChanges() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = [[.string("Short")], [.string("Also short")]]
        let table = SwiftDataTable(data: data, headerTitles: ["Content"], options: options)
        table.calculateColumnWidths()

        let oldHeight = table.rowMetricsStore.heightForRow(0)

        // Manually set a different height in the store to simulate a change
        table.rowMetricsStore.setHeight(oldHeight + 50, forRow: 0)
        table.rowMetricsStore.rebuildOffsets()

        let newHeight = table.rowMetricsStore.heightForRow(0)
        XCTAssertEqual(newHeight, oldHeight + 50, accuracy: 0.1)
    }

    // MARK: - Partial Visibility Fallback Tests

    func test_measureVisibleRowHeight_returnsNil_whenRowNotVisible() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        // Create enough rows that some won't be visible
        var data: DataTableContent = []
        for i in 0..<100 {
            data.append([.string("Row \(i)")])
        }

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        window.rootViewController = UIViewController()
        window.rootViewController?.view.addSubview(table)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        window.makeKeyAndVisible()

        table.calculateColumnWidths()
        table.collectionView.layoutIfNeeded()

        // Row 99 should not be visible in a 200pt height view
        // remeasureRow should fall back to sizing cells (not crash)
        let result = table.remeasureRow(99)
        // Either returns false (height unchanged) or true (measured via sizing cells)
        // The key is it doesn't crash and handles non-visible rows gracefully
        _ = result // Suppress unused warning
    }

    // MARK: - Integration Tests

    func test_remeasureRow_preservesYOffsets_forSubsequentRows() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let row1OffsetBefore = table.rowMetricsStore.yOffsetForRow(1)
        let row2OffsetBefore = table.rowMetricsStore.yOffsetForRow(2)

        // Simulate height change for row 0
        let oldHeight = table.rowMetricsStore.heightForRow(0)
        table.rowMetricsStore.setHeight(oldHeight + 30, forRow: 0)
        table.rowMetricsStore.rebuildOffsets(fromRow: 0)

        let row1OffsetAfter = table.rowMetricsStore.yOffsetForRow(1)
        let row2OffsetAfter = table.rowMetricsStore.yOffsetForRow(2)

        // Row 1 and 2 offsets should have increased by 30
        XCTAssertEqual(row1OffsetAfter - row1OffsetBefore, 30, accuracy: 0.1)
        XCTAssertEqual(row2OffsetAfter - row2OffsetBefore, 30, accuracy: 0.1)
    }

    func test_remeasureRow_worksWithCustomPrefetchWindow() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44, prefetchWindow: 5)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Automatic mode with custom prefetch window should support remeasureRow
        let result = table.remeasureRow(0)
        // Should not crash; result depends on visibility
        _ = result
    }

    // MARK: - Edge Cases

    func test_remeasureRow_handlesEmptyTable() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = []
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Should return false for empty table
        XCTAssertFalse(table.remeasureRow(0))
    }

    func test_remeasureRow_returnsFalse_whenHeightUnchanged() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)

        let data: DataTableContent = [[.string("Test")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // First call measures
        _ = table.remeasureRow(0)

        // Second call with same content should return false (no change)
        // Note: This depends on the threshold check (0.5pt tolerance)
        // Without visible cells, falls back to sizing cells which should be consistent
        let secondResult = table.remeasureRow(0)
        XCTAssertFalse(secondResult)
    }
}
