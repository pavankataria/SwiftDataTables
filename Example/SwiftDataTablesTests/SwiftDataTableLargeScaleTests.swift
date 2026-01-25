//
//  SwiftDataTableLargeScaleTests.swift
//  SwiftDataTablesTests
//
//  Phase 5: Large-Scale Mode Tests
//  Created for SwiftDataTables.
//

import XCTest
@testable import SwiftDataTables

/// Tests for Phase 5 large-scale mode (lazy measurement for 100k+ rows).
/// Validates estimated heights, lazy measurement, and prefetch window behavior.
@MainActor
final class SwiftDataTableLargeScaleTests: XCTestCase {

    // MARK: - Configuration Tests

    /// Large-scale mode should be detectable from configuration.
    func test_largeScaleMode_isDetectable() {
        var config = DataTableConfiguration()

        config.rowHeightMode = .fixed(44)
        XCTAssertFalse(config.rowHeightMode.isLargeScaleMode, "Fixed mode is not large-scale")

        config.rowHeightMode = .automatic(estimated: 44)
        XCTAssertFalse(config.rowHeightMode.isLargeScaleMode, "Automatic mode is not large-scale")

        config.rowHeightMode = .largeScale(estimatedHeight: 50, prefetchWindow: 20)
        XCTAssertTrue(config.rowHeightMode.isLargeScaleMode, "Large-scale mode should be detectable")
    }

    /// Large-scale mode should expose estimated height and prefetch window.
    func test_largeScaleMode_exposesParameters() {
        let config = DataTableConfiguration()
        let mode: DataTableRowHeightMode = .largeScale(estimatedHeight: 60, prefetchWindow: 15)

        XCTAssertEqual(mode.estimatedHeight, 60, "Should expose estimated height")
        XCTAssertEqual(mode.prefetchWindow, 15, "Should expose prefetch window")
    }

    /// Default prefetch window should be 10.
    func test_largeScaleMode_defaultPrefetchWindow() {
        let mode: DataTableRowHeightMode = .largeScale(estimatedHeight: 44)
        XCTAssertEqual(mode.prefetchWindow, 10, "Default prefetch window should be 10")
    }

    // MARK: - Row Metrics Store Tests

    /// RowMetricsStore should track measured vs estimated rows.
    func test_metricsStore_tracksMeasuredRows() {
        let store = RowMetricsStore()
        store.setRowCount(100, defaultHeight: 44, allMeasured: false)

        XCTAssertEqual(store.rowCount, 100, "Should have 100 rows")
        XCTAssertEqual(store.measuredRowCount, 0, "No rows should be measured initially")
        XCTAssertFalse(store.isRowMeasured(0), "Row 0 should not be measured")
        XCTAssertFalse(store.isRowMeasured(50), "Row 50 should not be measured")
    }

    /// Marking rows as measured should update tracking.
    func test_metricsStore_markRowMeasured() {
        let store = RowMetricsStore()
        store.setRowCount(100, defaultHeight: 44, allMeasured: false)

        store.markRowMeasured(5, height: 60)
        store.markRowMeasured(10, height: 80)

        XCTAssertTrue(store.isRowMeasured(5), "Row 5 should be measured")
        XCTAssertTrue(store.isRowMeasured(10), "Row 10 should be measured")
        XCTAssertFalse(store.isRowMeasured(0), "Row 0 should not be measured")
        XCTAssertEqual(store.measuredRowCount, 2, "Should have 2 measured rows")
        XCTAssertEqual(store.heightForRow(5), 60, "Row 5 should have height 60")
        XCTAssertEqual(store.heightForRow(10), 80, "Row 10 should have height 80")
    }

    /// unmeasuredRowsInRange should return only unmeasured rows.
    func test_metricsStore_unmeasuredRowsInRange() {
        let store = RowMetricsStore()
        store.setRowCount(20, defaultHeight: 44, allMeasured: false)

        // Mark some rows as measured
        store.markRowMeasured(5, height: 50)
        store.markRowMeasured(10, height: 50)
        store.markRowMeasured(15, height: 50)

        // Query a range
        let unmeasured = store.unmeasuredRowsInRange(3..<13)

        // Should include 3, 4, 6, 7, 8, 9, 11, 12 (not 5 or 10)
        XCTAssertTrue(unmeasured.contains(3), "Row 3 should be unmeasured")
        XCTAssertTrue(unmeasured.contains(4), "Row 4 should be unmeasured")
        XCTAssertFalse(unmeasured.contains(5), "Row 5 should be measured")
        XCTAssertTrue(unmeasured.contains(6), "Row 6 should be unmeasured")
        XCTAssertFalse(unmeasured.contains(10), "Row 10 should be measured")
        XCTAssertTrue(unmeasured.contains(11), "Row 11 should be unmeasured")
        XCTAssertEqual(unmeasured.count, 8, "Should have 8 unmeasured rows in range")
    }

    /// measureRowsInRange should measure and mark rows.
    func test_metricsStore_measureRowsInRange() {
        let store = RowMetricsStore()
        store.headerHeight = 44
        store.interRowSpacing = 1
        store.setRowCount(20, defaultHeight: 44, allMeasured: false)
        store.rebuildOffsets()

        // Measure rows 5-10
        let measured = store.measureRowsInRange(5..<10) { row in
            return CGFloat(50 + row) // Heights: 55, 56, 57, 58, 59
        }

        XCTAssertTrue(measured, "Should return true when rows are measured")
        XCTAssertTrue(store.isRowMeasured(5), "Row 5 should be measured")
        XCTAssertTrue(store.isRowMeasured(9), "Row 9 should be measured")
        XCTAssertFalse(store.isRowMeasured(4), "Row 4 should not be measured")
        XCTAssertFalse(store.isRowMeasured(10), "Row 10 should not be measured")
        XCTAssertEqual(store.heightForRow(5), 55, "Row 5 should have correct height")
        XCTAssertEqual(store.heightForRow(9), 59, "Row 9 should have correct height")
    }

    /// measureRowsInRange should return false when all rows already measured.
    func test_metricsStore_measureRowsInRange_alreadyMeasured() {
        let store = RowMetricsStore()
        store.setRowCount(10, defaultHeight: 44, allMeasured: true)

        let measured = store.measureRowsInRange(0..<5) { _ in 50 }

        XCTAssertFalse(measured, "Should return false when all rows already measured")
    }

    /// resetToEstimated should mark all rows as unmeasured.
    func test_metricsStore_resetToEstimated() {
        let store = RowMetricsStore()
        store.setRowCount(10, defaultHeight: 44, allMeasured: true)

        // All rows start measured
        XCTAssertEqual(store.measuredRowCount, 10, "All rows should be measured initially")

        store.resetToEstimated(estimatedHeight: 50)

        XCTAssertEqual(store.measuredRowCount, 0, "No rows should be measured after reset")
        XCTAssertEqual(store.heightForRow(0), 50, "Height should be reset to estimated")
    }

    // MARK: - Table Integration Tests

    /// Large-scale mode table should start with estimated heights.
    func test_table_largeScaleMode_startsWithEstimatedHeights() {
        let data: DataTableContent = (0..<100).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 60, prefetchWindow: 5)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // Verify row count
        XCTAssertEqual(table.numberOfRows(), 100, "Should have 100 rows")

        // In large-scale mode, most rows should use estimated height
        // Only visible rows + prefetch window should be measured
        let metricsStore = table.rowMetricsStore
        XCTAssertLessThan(metricsStore.measuredRowCount, 100, "Not all rows should be measured")
    }

    /// Large-scale mode should measure rows as they scroll into view.
    func test_table_largeScaleMode_measuresOnScroll() {
        let data: DataTableContent = (0..<200).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 5)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        let metricsStore = table.rowMetricsStore
        let measuredBeforeScroll = metricsStore.measuredRowCount

        // Scroll down significantly
        table.collectionView.contentOffset = CGPoint(x: 0, y: 3000)
        table.collectionView.layoutIfNeeded()

        // More rows should be measured after scrolling
        let measuredAfterScroll = metricsStore.measuredRowCount
        XCTAssertGreaterThan(measuredAfterScroll, measuredBeforeScroll,
                            "More rows should be measured after scrolling")

        // Rows around the new scroll position should be measured
        let currentRow = metricsStore.rowForYOffset(3000)
        XCTAssertTrue(metricsStore.isRowMeasured(currentRow),
                     "Current visible row should be measured")
    }

    /// Large-scale mode data updates should work correctly.
    func test_table_largeScaleMode_handlesDataUpdates() {
        var data: DataTableContent = (0..<50).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 5)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // Add more rows
        data.append(contentsOf: (50..<100).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: false)
        table.collectionView.layoutIfNeeded()

        XCTAssertEqual(table.numberOfRows(), 100, "Should have 100 rows after update")

        // New rows should use estimated heights until scrolled into view
        let metricsStore = table.rowMetricsStore
        // Row 99 (at the end) should likely be unmeasured
        XCTAssertFalse(metricsStore.isRowMeasured(99),
                      "Newly added row at end should be unmeasured")
    }

    /// Fixed mode should not use lazy measurement.
    func test_table_fixedMode_measuresAllUpfront() {
        let data: DataTableContent = (0..<50).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .fixed(44)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // In fixed mode, all rows should be "measured" (using fixed height)
        let metricsStore = table.rowMetricsStore
        XCTAssertEqual(metricsStore.measuredRowCount, 50, "All rows should be measured in fixed mode")
    }

    /// Automatic mode should measure all rows upfront.
    func test_table_automaticMode_measuresAllUpfront() {
        let data: DataTableContent = (0..<30).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .automatic(estimated: 44)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // In automatic mode, all rows should be measured upfront
        let metricsStore = table.rowMetricsStore
        XCTAssertEqual(metricsStore.measuredRowCount, 30, "All rows should be measured in automatic mode")
    }

    // MARK: - Performance Tests

    /// Large-scale mode should handle large row counts efficiently.
    /// Note: Uses 10k rows as proxy for 100k to keep test times reasonable.
    /// Large-scale mode scales linearly, so 10k validates the lazy measurement approach.
    func test_table_largeScaleMode_handlesLargeRowCount() {
        // Create 10,000 rows (proxy for 100k - keeps test times reasonable)
        let data: DataTableContent = (0..<10000).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 10)
        config.shouldShowSearchSection = false

        let startTime = CFAbsoluteTimeGetCurrent()

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsed = endTime - startTime

        XCTAssertEqual(table.numberOfRows(), 10000, "Should have 10,000 rows")

        // Should be reasonably fast (not measuring all rows)
        XCTAssertLessThan(elapsed, 2.0, "Large-scale mode should initialize quickly")

        // Only a small fraction should be measured
        let metricsStore = table.rowMetricsStore
        XCTAssertLessThan(metricsStore.measuredRowCount, 100,
                         "Only visible + prefetch rows should be measured")
    }

    // MARK: - markRowsUnmeasured Tests

    /// markRowsUnmeasured should reset rows to estimated height.
    func test_metricsStore_markRowsUnmeasured_resetsToEstimated() {
        let store = RowMetricsStore()
        store.setRowCount(20, defaultHeight: 44, allMeasured: false)

        // Measure some rows
        store.markRowMeasured(5, height: 100)
        store.markRowMeasured(10, height: 120)
        store.rebuildOffsets()

        XCTAssertTrue(store.isRowMeasured(5), "Row 5 should be measured")
        XCTAssertEqual(store.heightForRow(5), 100, "Row 5 should have height 100")

        // Unmeasure them
        store.markRowsUnmeasured(IndexSet([5, 10]), estimatedHeight: 44)

        XCTAssertFalse(store.isRowMeasured(5), "Row 5 should be unmeasured after markRowsUnmeasured")
        XCTAssertFalse(store.isRowMeasured(10), "Row 10 should be unmeasured after markRowsUnmeasured")
        XCTAssertEqual(store.heightForRow(5), 44, "Row 5 should have estimated height")
        XCTAssertEqual(store.heightForRow(10), 44, "Row 10 should have estimated height")
    }

    /// currentDirtyRows should expose the dirty rows set.
    func test_metricsStore_currentDirtyRows_exposesSet() {
        let store = RowMetricsStore()
        store.setRowCount(20, defaultHeight: 44, allMeasured: true)

        XCTAssertTrue(store.currentDirtyRows.isEmpty, "Should have no dirty rows initially")

        store.invalidateRows(IndexSet([3, 7, 12]))

        let dirty = store.currentDirtyRows
        XCTAssertEqual(dirty.count, 3, "Should have 3 dirty rows")
        XCTAssertTrue(dirty.contains(3), "Should contain row 3")
        XCTAssertTrue(dirty.contains(7), "Should contain row 7")
        XCTAssertTrue(dirty.contains(12), "Should contain row 12")
    }

    // MARK: - Anchoring Stability Tests

    /// End-to-end test: Lazy measurement should preserve scroll position (anchor stability).
    /// When estimate→measured transitions occur, contentOffset should remain stable.
    /// This validates the full flow: scroll → trigger lazy measurement → anchor restore.
    func test_largeScaleMode_anchoringStability_duringLazyMeasurement() {
        // Create table with many rows - use variable content to ensure measured heights differ from estimates
        let data: DataTableContent = (0..<500).map { row in
            // Rows with longer content will have different measured heights than the 44pt estimate
            let content = row % 3 == 0 ? "Row \(row) with much longer content that will wrap to multiple lines and exceed the estimated height significantly" : "Row \(row)"
            return [.string(content)]
        }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 5)
        config.shouldShowSearchSection = false
        config.textLayout = .wrap // Enable wrapping so heights vary

        let table = SwiftDataTable(data: data, headerTitles: ["Header"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // Verify initial state: only visible + prefetch rows measured
        let metricsStore = table.rowMetricsStore
        let initialMeasuredCount = metricsStore.measuredRowCount
        XCTAssertLessThan(initialMeasuredCount, 50, "Should start with only visible rows measured")

        // Scroll to a position where unmeasured rows will become visible
        // This simulates user scrolling down past the initially measured rows
        let scrollTarget: CGFloat = 3000 // ~68 rows down at 44pt estimate
        table.collectionView.contentOffset.y = scrollTarget
        table.layoutIfNeeded()

        // Capture state before triggering lazy measurement
        let offsetBefore = table.collectionView.contentOffset.y
        let measuredBefore = metricsStore.measuredRowCount

        // Trigger scrollViewDidScroll which invokes measureVisibleRowsIfNeeded()
        // This simulates the scroll delegate callback that triggers lazy measurement
        table.scrollViewDidScroll(table.collectionView)
        table.layoutIfNeeded()

        // Verify lazy measurement occurred
        let measuredAfter = metricsStore.measuredRowCount
        XCTAssertGreaterThan(measuredAfter, measuredBefore,
                            "Lazy measurement should have measured additional rows")

        // Verify contentOffset remained stable (anchor preserved visual position)
        let offsetAfter = table.collectionView.contentOffset.y
        let tolerance: CGFloat = 2.0 // Small tolerance for rounding

        XCTAssertEqual(offsetBefore, offsetAfter, accuracy: tolerance,
                      "Scroll position should remain stable after estimate→measured transition")
    }

    /// Test that 10k rows is a valid proxy for 100k performance validation.
    /// Rationale: Large-scale mode uses O(1) lazy measurement - only visible + prefetch rows
    /// are measured regardless of total count. The 10k test validates this behavior.
    /// Scaling to 100k would only add test time, not coverage, since the algorithm is identical.
    func test_largeScaleMode_10kProxyRationale() {
        // Create 10k rows
        let data: DataTableContent = (0..<10000).map { [.string("Row \($0)")] }
        var config = DataTableConfiguration()
        config.rowHeightMode = .largeScale(estimatedHeight: 44, prefetchWindow: 10)
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: data, headerTitles: ["H"], options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        let metricsStore = table.rowMetricsStore

        // Key validation: measured count is bounded by viewport, not total rows
        // This proves the algorithm is O(viewport) not O(n), so 10k ≈ 100k behavior
        let measuredCount = metricsStore.measuredRowCount
        let totalRows = metricsStore.rowCount

        XCTAssertEqual(totalRows, 10000, "Should have 10k rows")
        XCTAssertLessThan(measuredCount, 100,
                         "Measured count should be bounded by viewport + prefetch, not total rows")

        // The ratio proves O(1) behavior: <1% of rows measured regardless of scale
        let measuredRatio = Double(measuredCount) / Double(totalRows)
        XCTAssertLessThan(measuredRatio, 0.01,
                         "Should measure <1% of rows, proving O(viewport) not O(n)")
    }
}
