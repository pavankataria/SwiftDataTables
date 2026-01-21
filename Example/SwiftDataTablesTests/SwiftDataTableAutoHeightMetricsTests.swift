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
        table.calculateColumnWidths()

        let shortHeight = table.rowMetricsStore.heightForRow(0)
        let longHeight = table.rowMetricsStore.heightForRow(1)

        // Long text should result in taller row
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
