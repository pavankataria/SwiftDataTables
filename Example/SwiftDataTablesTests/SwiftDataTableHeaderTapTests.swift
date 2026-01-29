//
//  SwiftDataTableHeaderTapTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 29/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for the `didTapHeaderAt` delegate method.
///
/// These tests verify:
/// - Delegate is called when header is tapped
/// - Correct column index is passed to delegate
/// - Delegate is called regardless of whether sorting occurs
/// - Works in combination with `isColumnSortable` closure
@MainActor
class SwiftDataTableHeaderTapTests: XCTestCase {

    // MARK: - Mock Delegate

    /// Mock delegate that captures header tap events for testing
    class MockDelegate: NSObject, SwiftDataTableDelegate {
        var tappedColumnIndices: [Int] = []
        var didTapHeaderAtCallCount: Int { tappedColumnIndices.count }

        func dataTable(_ dataTable: SwiftDataTable, didTapHeaderAt columnIndex: Int) {
            tappedColumnIndices.append(columnIndex)
        }
    }

    // MARK: - Test Helpers

    private func createDataTable(
        data: [[String]] = [["A", "B", "C"], ["D", "E", "F"]],
        headers: [String] = ["Col1", "Col2", "Col3"],
        isColumnSortable: ((Int) -> Bool)? = nil
    ) -> SwiftDataTable {
        var config = DataTableConfiguration()
        config.isColumnSortable = isColumnSortable
        return SwiftDataTable(
            data: data,
            headerTitles: headers,
            options: config,
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )
    }

    // MARK: - Delegate Called Tests

    func test_headerTap_callsDelegate() {
        let dataTable = createDataTable()
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Simulate header tap on column 0
        dataTable.didTapColumn(index: IndexPath(index: 0))

        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
    }

    func test_headerTap_passesCorrectColumnIndex() {
        let dataTable = createDataTable()
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Tap column 1
        dataTable.didTapColumn(index: IndexPath(index: 1))

        XCTAssertEqual(mockDelegate.tappedColumnIndices.last, 1)
    }

    func test_multipleHeaderTaps_callsDelegateEachTime() {
        let dataTable = createDataTable()
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Tap columns 0, 2, 1
        dataTable.didTapColumn(index: IndexPath(index: 0))
        dataTable.didTapColumn(index: IndexPath(index: 2))
        dataTable.didTapColumn(index: IndexPath(index: 1))

        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 3)
        XCTAssertEqual(mockDelegate.tappedColumnIndices, [0, 2, 1])
    }

    // MARK: - Delegate Called Regardless of Sortability Tests

    func test_headerTap_callsDelegate_evenWhenColumnNotSortable() {
        let dataTable = createDataTable(isColumnSortable: { $0 != 1 })
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Tap non-sortable column 1
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // Delegate should still be called
        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
        XCTAssertEqual(mockDelegate.tappedColumnIndices.last, 1)
    }

    func test_headerTap_callsDelegate_whenAllColumnsNotSortable() {
        let dataTable = createDataTable(isColumnSortable: { _ in false })
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Tap all columns
        dataTable.didTapColumn(index: IndexPath(index: 0))
        dataTable.didTapColumn(index: IndexPath(index: 1))
        dataTable.didTapColumn(index: IndexPath(index: 2))

        // Delegate should be called for all taps
        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 3)
        XCTAssertEqual(mockDelegate.tappedColumnIndices, [0, 1, 2])
    }

    // MARK: - Sorting Still Works Tests

    func test_headerTap_sortingStillOccurs_forSortableColumns() {
        let dataTable = createDataTable()
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        let initialSortType = dataTable.headerViewModels[0].sortType

        // Tap sortable column
        dataTable.didTapColumn(index: IndexPath(index: 0))

        // Both delegate called AND sorting occurred
        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, initialSortType)
    }

    func test_headerTap_sortingDoesNotOccur_forNonSortableColumns() {
        let dataTable = createDataTable(isColumnSortable: { $0 != 1 })
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        let initialSortType = dataTable.headerViewModels[1].sortType

        // Tap non-sortable column
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // Delegate called but sorting did NOT occur
        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, initialSortType)
    }

    // MARK: - No Delegate Set Tests

    func test_headerTap_doesNotCrash_withNoDelegate() {
        let dataTable = createDataTable()

        // Should not crash when no delegate is set
        dataTable.didTapColumn(index: IndexPath(index: 0))
        dataTable.didTapColumn(index: IndexPath(index: 1))
        dataTable.didTapColumn(index: IndexPath(index: 2))

        // No assertion needed - test passes if no crash occurs
    }

    // MARK: - Edge Cases

    func test_headerTap_singleColumn() {
        let dataTable = createDataTable(
            data: [["X"]],
            headers: ["Single"]
        )
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        dataTable.didTapColumn(index: IndexPath(index: 0))

        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
        XCTAssertEqual(mockDelegate.tappedColumnIndices.last, 0)
    }

    func test_headerTap_emptyTable_stillCallsDelegate() {
        let dataTable = createDataTable(
            data: [],
            headers: ["A", "B", "C"]
        )
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        dataTable.didTapColumn(index: IndexPath(index: 1))

        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 1)
        XCTAssertEqual(mockDelegate.tappedColumnIndices.last, 1)
    }

    func test_headerTap_rapidSuccessiveTaps_allCaptured() {
        let dataTable = createDataTable()
        let mockDelegate = MockDelegate()
        dataTable.delegate = mockDelegate

        // Rapid taps on same column
        for _ in 0..<10 {
            dataTable.didTapColumn(index: IndexPath(index: 0))
        }

        XCTAssertEqual(mockDelegate.didTapHeaderAtCallCount, 10)
    }
}
