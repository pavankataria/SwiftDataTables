//
//  SwiftDataTableAutoHeightMetricsTests.swift
//  SwiftDataTablesTests
//
//  Regression tests for auto-height layout with RowMetricsStore.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableAutoHeightMetricsTests: XCTestCase {

    // MARK: - RowMetricsStore Basic Tests

    func test_metricsStore_initializedWithCorrectRowCount() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 3)
    }

    func test_metricsStore_heightForRow_matchesTableHeight() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(60)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 60)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 60)
    }

    func test_metricsStore_yOffsets_areCumulative() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 30

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Row 0 starts after header
        XCTAssertEqual(store.yOffsetForRow(0), 30, accuracy: 0.1)

        // Row 1 starts after row 0 (header + row0Height + spacing)
        let expectedRow1Y = 30 + 50 + options.heightOfInterRowSpacing
        XCTAssertEqual(store.yOffsetForRow(1), expectedRow1Y, accuracy: 0.1)
    }

    func test_metricsStore_contentHeight_includesAllRowsAndFooter() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(40)
        options.heightForSectionHeader = 20

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        let spacing = options.heightOfInterRowSpacing

        // contentHeight = header + (row0 + spacing) + (row1 + spacing) + footer
        let expectedHeight = 20 + (40 + spacing) + (40 + spacing) + store.footerHeight
        XCTAssertEqual(store.contentHeight, expectedHeight, accuracy: 0.1)
    }

    // MARK: - Auto-Height Update Tests

    func test_metricsStore_updatedAfterSetData() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 1)

        // Update with more rows
        let newData: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        table.setData(newData, animatingDifferences: false)

        XCTAssertEqual(table.rowMetricsStore.rowCount, 3)
    }

    func test_metricsStore_rebuiltAfterRecalculate() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)

        // Verify heights are correctly stored
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 44)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 44)

        // Recalculating maintains consistency
        table.calculateColumnWidths()
        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 44)
    }

    func test_autoHeightDiff_updatesMetricsForItemReloads() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)
        options.textLayout = .wrap
        options.columnWidthMode = .fixed(width: 80)
        options.minColumnWidth = 80
        options.maxColumnWidth = 80
        options.shouldContentWidthScaleToFillFrame = false
        options.shouldShowSearchSection = false

        let identifiers = ["1", "2"]
        let data: DataTableContent = [[.string("Short")], [.string("Short 2")]]
        let table = makeTableInWindow(data: data, headerTitles: ["H"], options: options)

        // Seed identifiers without animation so diff path uses reloadItems on update.
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        let initialHeight = table.rowMetricsStore.heightForRow(0)
        let initialOffset1 = table.rowMetricsStore.yOffsetForRow(1)

        let longText = String(repeating: "Wrap ", count: 30)
        let newData: DataTableContent = [[.string(longText)], [.string("Short 2")]]

        let exp = expectation(description: "diff complete")
        table.setData(newData, rowIdentifiers: identifiers, animatingDifferences: true) { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        table.collectionView.layoutIfNeeded()

        let updatedHeight = table.rowMetricsStore.heightForRow(0)
        let updatedOffset1 = table.rowMetricsStore.yOffsetForRow(1)

        XCTAssertGreaterThan(updatedHeight, initialHeight)
        XCTAssertGreaterThan(updatedOffset1, initialOffset1)
    }

    func test_fixedHeightDiff_midInsert_updatesOffsets() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0
        options.shouldSectionFootersFloat = false
        options.shouldShowFooter = false
        options.shouldShowSearchSection = false
        options.shouldContentWidthScaleToFillFrame = false

        let initialData: DataTableContent = [[.string("A")], [.string("C")]]
        let table = makeTableInWindow(data: initialData, headerTitles: ["H"], options: options)

        // Seed identifiers so diff path runs on insertion
        table.setData(initialData, rowIdentifiers: ["r0", "r2"], animatingDifferences: false)

        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(0), 0, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(1), 50, accuracy: 0.1)

        let newData: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let exp = expectation(description: "diff complete")
        table.setData(newData, rowIdentifiers: ["r0", "r1", "r2"], animatingDifferences: true) { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        table.collectionView.layoutIfNeeded()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 3)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(0), 0, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(1), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(2), 100, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(2), 50, accuracy: 0.1)
    }

    func test_fixedHeightDiff_midDelete_updatesOffsets() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0
        options.shouldSectionFootersFloat = false
        options.shouldShowFooter = false
        options.shouldShowSearchSection = false
        options.shouldContentWidthScaleToFillFrame = false

        let initialData: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = makeTableInWindow(data: initialData, headerTitles: ["H"], options: options)

        // Seed identifiers so diff path runs on deletion
        table.setData(initialData, rowIdentifiers: ["r0", "r1", "r2"], animatingDifferences: false)

        XCTAssertEqual(table.rowMetricsStore.rowCount, 3)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(0), 0, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(1), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(2), 100, accuracy: 0.1)

        let newData: DataTableContent = [[.string("A")], [.string("C")]]
        let exp = expectation(description: "diff complete")
        table.setData(newData, rowIdentifiers: ["r0", "r2"], animatingDifferences: true) { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        table.collectionView.layoutIfNeeded()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(0), 0, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.yOffsetForRow(1), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 50, accuracy: 0.1)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 50, accuracy: 0.1)
    }

    // MARK: - Automatic Row Height Tests

    func test_automaticHeight_metricsStore_reflectsWrappedText() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)
        options.textLayout = .wrap
        options.columnWidthMode = .fixed(width: 80)
        options.minColumnWidth = 0
        options.maxColumnWidth = 80

        let shortText = "Short"
        let longText = String(repeating: "Wrap ", count: 30)

        let data: DataTableContent = [[.string(shortText)], [.string(longText)]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)

        // Embed in window to trigger lazy measurement
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        let shortHeight = table.rowMetricsStore.heightForRow(0)
        let longHeight = table.rowMetricsStore.heightForRow(1)

        // Long text should result in taller row after measurement
        XCTAssertGreaterThan(longHeight, shortHeight)
    }

    // MARK: - Binary Search Tests

    func test_metricsStore_rowForYOffset_findsCorrectRow() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 20

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Y=0 should find row 0
        XCTAssertEqual(store.rowForYOffset(0), 0)

        // Y=25 (in header area) should find row 0
        XCTAssertEqual(store.rowForYOffset(25), 0)

        // Y=30 (start of row 0) should find row 0
        XCTAssertEqual(store.rowForYOffset(30), 0)

        // Y in middle of row 1 should find row 1
        let row1Y = store.yOffsetForRow(1)
        XCTAssertEqual(store.rowForYOffset(row1Y + 25), 1)
    }

    // MARK: - Footer Height Edge Cases (GPT Review Issue #2)

    func test_metricsStore_footerHeight_zeroWhenNotFloating() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)
        options.shouldSectionFootersFloat = false  // Non-floating footer
        options.shouldShowFooter = true

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Non-floating footer should NOT contribute to content height
        XCTAssertEqual(table.rowMetricsStore.footerHeight, 0)
    }

    func test_metricsStore_footerHeight_includedWhenFloating() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)
        options.shouldSectionFootersFloat = true  // Floating footer
        options.shouldShowFooter = true
        options.heightForSectionFooter = 30

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Floating footer SHOULD contribute to content height
        XCTAssertGreaterThan(table.rowMetricsStore.footerHeight, 0)
    }

    // MARK: - Delegate Height Precedence Tests (GPT Review Issue #1)

    func test_metricsStore_delegateHeights_takePrecedenceOverFixedMode() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)  // Fixed mode set to 44

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)

        // Create and assign mock delegate that returns different heights per row
        let mockDelegate = MockHeightDelegate(heights: [100, 150, 200])
        table.delegate = mockDelegate

        table.calculateColumnWidths()

        // Delegate heights should take precedence over fixed(44)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 100)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 150)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(2), 200)
    }

    func test_metricsStore_delegateHeights_takePrecedenceOverAutomaticMode() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)  // Automatic mode

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)

        // Create and assign mock delegate
        let mockDelegate = MockHeightDelegate(heights: [75, 125])
        table.delegate = mockDelegate

        table.calculateColumnWidths()

        // Delegate heights should take precedence over automatic calculation
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 75)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 125)
    }

    private func makeTableInWindow(
        data: DataTableContent,
        headerTitles: [String],
        options: DataTableConfiguration
    ) -> SwiftDataTable {
        let table = SwiftDataTable(data: data, headerTitles: headerTitles, options: options)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: table.frame)
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        return table
    }
}

// MARK: - Phase 3: Dirty Tracking Infrastructure Tests

extension SwiftDataTableAutoHeightMetricsTests {

    func test_metricsStore_dirtyTracking_initiallyEmpty() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        XCTAssertFalse(table.rowMetricsStore.hasDirtyRows)
        XCTAssertNil(table.rowMetricsStore.earliestDirtyRow)
    }

    func test_metricsStore_invalidateRows_marksDirty() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        table.rowMetricsStore.invalidateRows(IndexSet([1]))

        XCTAssertTrue(table.rowMetricsStore.hasDirtyRows)
        XCTAssertEqual(table.rowMetricsStore.earliestDirtyRow, 1)
    }

    func test_metricsStore_invalidateRows_tracksMultiple() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        table.rowMetricsStore.invalidateRows(IndexSet([1, 3]))

        XCTAssertTrue(table.rowMetricsStore.hasDirtyRows)
        XCTAssertEqual(table.rowMetricsStore.earliestDirtyRow, 1)
    }

    func test_metricsStore_clearDirtyFlags_removesAllDirty() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        table.rowMetricsStore.invalidateRows(IndexSet([0, 1]))
        XCTAssertTrue(table.rowMetricsStore.hasDirtyRows)

        table.rowMetricsStore.clearDirtyFlags()

        XCTAssertFalse(table.rowMetricsStore.hasDirtyRows)
        XCTAssertNil(table.rowMetricsStore.earliestDirtyRow)
    }

    func test_metricsStore_rebuildOffsetsFromRow_updatesOnlyTailRows() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 20
        options.heightOfInterRowSpacing = 0

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Initial offsets: 20, 70, 120, 170 (header=20, each row=50)
        let initialOffset0 = store.yOffsetForRow(0)
        let initialOffset1 = store.yOffsetForRow(1)

        // Change row 1 height
        store.setHeight(100, forRow: 1)

        // Rebuild from row 1
        store.rebuildOffsets(fromRow: 1)

        // Row 0 offset unchanged
        XCTAssertEqual(store.yOffsetForRow(0), initialOffset0)

        // Row 1 offset unchanged (same position, different height)
        XCTAssertEqual(store.yOffsetForRow(1), initialOffset1)

        // Row 2 offset should shift: 20 + 50 + 100 = 170 (was 120)
        XCTAssertEqual(store.yOffsetForRow(2), 170)

        // Row 3 offset should shift: 170 + 50 = 220 (was 170)
        XCTAssertEqual(store.yOffsetForRow(3), 220)
    }

    func test_metricsStore_appendRow_increasesCount() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        XCTAssertEqual(store.rowCount, 2)

        store.appendRow(height: 60)

        XCTAssertEqual(store.rowCount, 3)
        XCTAssertEqual(store.heightForRow(2), 60)
    }

    func test_metricsStore_truncateToCount_decreasesCount() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        XCTAssertEqual(store.rowCount, 4)

        store.truncateToCount(2)

        XCTAssertEqual(store.rowCount, 2)
    }

    func test_metricsStore_truncateToCount_clearsDirtyFlagsForRemovedRows() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")], [.string("D")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        store.invalidateRows(IndexSet([2, 3]))  // Mark rows 2 and 3 as dirty
        XCTAssertEqual(store.earliestDirtyRow, 2)

        store.truncateToCount(2)  // Remove rows 2 and 3

        // Dirty flags for removed rows should be cleared
        XCTAssertFalse(store.hasDirtyRows)
    }

    func test_metricsStore_recomputeDirtyHeights_measuresOnlyDirty() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Initial: all rows 50
        XCTAssertEqual(store.heightForRow(0), 50)
        XCTAssertEqual(store.heightForRow(1), 50)
        XCTAssertEqual(store.heightForRow(2), 50)

        // Mark only row 1 as dirty
        store.invalidateRows(IndexSet([1]))

        var measuredRows = [Int]()
        store.recomputeDirtyHeights { row in
            measuredRows.append(row)
            return 100  // New height
        }

        // Only row 1 should have been measured
        XCTAssertEqual(measuredRows, [1])

        // Only row 1 height changed
        XCTAssertEqual(store.heightForRow(0), 50)
        XCTAssertEqual(store.heightForRow(1), 100)
        XCTAssertEqual(store.heightForRow(2), 50)

        // Offsets updated from row 1
        XCTAssertEqual(store.yOffsetForRow(0), 0)
        XCTAssertEqual(store.yOffsetForRow(1), 50)
        XCTAssertEqual(store.yOffsetForRow(2), 150)  // 50 + 100

        // Dirty flags cleared
        XCTAssertFalse(store.hasDirtyRows)
    }
}

// MARK: - Phase 3: Integration Tests for Incremental Height Updates

extension SwiftDataTableAutoHeightMetricsTests {

    func test_incrementalHeightUpdate_updatesTailOffsets_whenWidthsUnchanged() {
        // Setup: Create table with fixed heights where we can control measurement
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 10
        options.heightOfInterRowSpacing = 0

        let initialData: DataTableContent = [
            [.string("Row0")],
            [.string("Row1")],
            [.string("Row2")]
        ]
        let table = SwiftDataTable(data: initialData, headerTitles: ["Header"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Verify initial state
        XCTAssertEqual(store.rowCount, 3)
        let initialOffset1 = store.yOffsetForRow(1)
        let initialOffset2 = store.yOffsetForRow(2)

        // Simulate a content change that marks row 1 as dirty
        store.invalidateRows(IndexSet([1]))
        store.setHeight(100, forRow: 1)  // Row 1 height doubles

        // Rebuild offsets from the dirty row
        store.rebuildOffsets(fromRow: 1)

        // Verify: row 0 offset unchanged, rows 1+ shifted
        XCTAssertEqual(store.yOffsetForRow(0), 10)  // header height
        XCTAssertEqual(store.yOffsetForRow(1), initialOffset1)  // Same position
        // Row 2 should be shifted by the height increase (100 - 50 = 50)
        XCTAssertEqual(store.yOffsetForRow(2), initialOffset2 + 50)
    }

    func test_incrementalHeightUpdate_handlesDeletion() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0
        options.shouldSectionFootersFloat = false

        let initialData: DataTableContent = [
            [.string("Row0")],
            [.string("Row1")],
            [.string("Row2")],
            [.string("Row3")]
        ]
        let table = SwiftDataTable(data: initialData, headerTitles: ["Header"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        store.footerHeight = 0  // Clear any footer height

        // Rebuild offsets after clearing footer
        store.rebuildOffsets()

        // Verify initial state
        XCTAssertEqual(store.rowCount, 4)
        XCTAssertEqual(store.yOffsetForRow(3), 150)  // 0 + 50 + 50 + 50

        // Simulate deletion of row 1
        store.truncateToCount(3)
        store.rebuildOffsets(fromRow: 1)

        // Verify: row count decreased
        XCTAssertEqual(store.rowCount, 3)
        // Row 2 (now last) should be at offset 100 (0 + 50 + 50)
        XCTAssertEqual(store.yOffsetForRow(2), 100)
    }

    func test_incrementalHeightUpdate_handlesInsertion() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0
        options.shouldSectionFootersFloat = false

        let initialData: DataTableContent = [
            [.string("Row0")],
            [.string("Row1")]
        ]
        let table = SwiftDataTable(data: initialData, headerTitles: ["Header"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore
        store.footerHeight = 0  // Clear any footer height
        store.rebuildOffsets()

        // Verify initial state
        XCTAssertEqual(store.rowCount, 2)
        XCTAssertEqual(store.contentHeight, 100)  // 50 + 50

        // Simulate insertion of a new row
        store.appendRow(height: 60)  // Insert with different height
        store.rebuildOffsets(fromRow: 2)

        // Verify: row count increased
        XCTAssertEqual(store.rowCount, 3)
        XCTAssertEqual(store.heightForRow(2), 60)
        XCTAssertEqual(store.yOffsetForRow(2), 100)  // After rows 0 and 1
        XCTAssertEqual(store.contentHeight, 160)  // 50 + 50 + 60
    }

    func test_incrementalHeightUpdate_preservesExistingRowHeights_onInsertion() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(50)
        options.heightForSectionHeader = 0
        options.heightOfInterRowSpacing = 0
        options.shouldSectionFootersFloat = false  // Disable footer

        let initialData: DataTableContent = [
            [.string("Row0")],
            [.string("Row1")]
        ]
        let table = SwiftDataTable(data: initialData, headerTitles: ["Header"], options: options)
        table.calculateColumnWidths()

        let store = table.rowMetricsStore

        // Clear any footer height the table may have set
        store.footerHeight = 0

        // Manually set different heights
        store.setHeight(30, forRow: 0)
        store.setHeight(40, forRow: 1)
        store.rebuildOffsets()

        XCTAssertEqual(store.heightForRow(0), 30)
        XCTAssertEqual(store.heightForRow(1), 40)
        XCTAssertEqual(store.contentHeight, 70)

        // Insert a new row
        store.appendRow(height: 50)
        store.rebuildOffsets(fromRow: 2)

        // Verify existing heights preserved
        XCTAssertEqual(store.heightForRow(0), 30)
        XCTAssertEqual(store.heightForRow(1), 40)
        XCTAssertEqual(store.heightForRow(2), 50)
        XCTAssertEqual(store.contentHeight, 120)
    }

    func test_incrementalDelete_preservesDelegateHeightsForRemainingRows() {
        // Test verifies that after deletion, remaining rows re-query delegate heights.
        // Delegate heights are index-based, so after deletion row indices shift.
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(44)
        options.shouldContentWidthScaleToFillFrame = false

        let data: DataTableContent = [[.string("A")], [.string("B")], [.string("C")]]
        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: options)
        // Keep strong reference to delegate (it's weak in SwiftDataTable)
        let mockDelegate = MockHeightDelegate(heights: [40, 80, 60])
        table.delegate = mockDelegate
        table.calculateColumnWidths()

        // Verify initial heights from delegate
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 40)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 80)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(2), 60)

        // Delete middle row (r1). After deletion, delegate is re-queried by NEW index.
        // Row 0 → heights[0] = 40, Row 1 → heights[1] = 80 (shifted from original r2)
        let newData: DataTableContent = [[.string("A")], [.string("C")]]
        let exp = expectation(description: "diff complete")
        table.setData(newData, rowIdentifiers: ["r0", "r2"], animatingDifferences: true) { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        table.collectionView.layoutIfNeeded()

        XCTAssertEqual(table.rowMetricsStore.rowCount, 2)
        XCTAssertEqual(table.rowMetricsStore.heightForRow(0), 40, "Row 0 retains height from delegate")
        XCTAssertEqual(table.rowMetricsStore.heightForRow(1), 80, "Row 1 gets delegate height at index 1 (delegate is index-based)")
    }
}

// MARK: - Mock Delegate for Height Testing

private final class MockHeightDelegate: NSObject, SwiftDataTableDelegate {
    private let heights: [CGFloat]

    init(heights: [CGFloat]) {
        self.heights = heights
        super.init()
    }

    func dataTable(_ dataTable: SwiftDataTable, heightForRowAt index: Int) -> CGFloat {
        guard index < heights.count else { return 44 }
        return heights[index]
    }
}
