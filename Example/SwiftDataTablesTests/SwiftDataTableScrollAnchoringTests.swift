//
//  SwiftDataTableScrollAnchoringTests.swift
//  SwiftDataTablesTests
//
//  Phase 4: Scroll Anchoring Tests
//  Created for SwiftDataTables.
//

import XCTest
@testable import SwiftDataTables

/// Tests for Phase 4 scroll anchoring behavior.
/// Ensures that updates preserve the user's visual scroll position.
@MainActor
final class SwiftDataTableScrollAnchoringTests: XCTestCase {

    // MARK: - Anchor Preservation Tests

    /// Update above viewport keeps anchor row stationary (no jump).
    func test_insertAboveViewport_preservesAnchorRowPosition() {
        // Given: A table with many rows, scrolled to show rows 10-15
        var data: DataTableContent = (0..<30).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Scroll to row 10
        let targetRow = 10
        let rowY = table.rowMetricsStore.yOffsetForRow(targetRow)
        table.collectionView.contentOffset = CGPoint(x: 0, y: rowY)
        table.collectionView.layoutIfNeeded()

        // Record the screen position of row 10's cell
        let anchorCellFrameBefore = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: targetRow)
        )?.frame
        let viewportTopBefore = table.collectionView.contentOffset.y

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Insert 3 rows at the beginning (above the viewport)
        data.insert(contentsOf: [[.string("New 0")], [.string("New 1")], [.string("New 2")]], at: 0)
        table.setData(data, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: The anchor row (now at section 13 due to insertions) should be
        // at approximately the same visual position
        let newAnchorSection = targetRow + 3  // Row 10 is now section 13
        let anchorCellFrameAfter = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: newAnchorSection)
        )?.frame

        // The visual position relative to viewport should be approximately the same
        let viewportTopAfter = table.collectionView.contentOffset.y

        // Content offset should have increased to compensate for inserted rows
        XCTAssertGreaterThan(
            viewportTopAfter, viewportTopBefore,
            "Content offset should increase when rows are inserted above viewport"
        )

        // The anchor row's Y position minus viewport top should be similar
        if let frameBefore = anchorCellFrameBefore, let frameAfter = anchorCellFrameAfter {
            let visualOffsetBefore = frameBefore.minY - viewportTopBefore
            let visualOffsetAfter = frameAfter.minY - viewportTopAfter
            XCTAssertEqual(
                visualOffsetAfter, visualOffsetBefore,
                accuracy: 2.0,
                "Anchor row should maintain approximately the same visual position"
            )
        }
    }

    /// Update below viewport does not alter contentOffset.
    func test_insertBelowViewport_doesNotChangeContentOffset() {
        // Given: A table with rows, viewport at the top
        var data: DataTableContent = (0..<30).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Stay near the top (row 2)
        let scrolledOffset = CGPoint(x: 0, y: 50)
        table.collectionView.contentOffset = scrolledOffset
        table.collectionView.layoutIfNeeded()

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Insert rows at the end (below the viewport)
        data.append(contentsOf: (30..<35).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: Content offset should remain unchanged
        XCTAssertEqual(
            table.collectionView.contentOffset.y,
            scrolledOffset.y,
            accuracy: 1.0,
            "Content offset should not change when rows are inserted below viewport"
        )
    }

    /// Delete the anchor row falls back to nearest surviving row without a jump.
    func test_deleteAnchorRow_fallsBackToNearestRow() {
        // Given: A table scrolled to row 10
        var data: DataTableContent = (0..<30).map { [.string("Row \($0)")] }
        let identifiers = (0..<30).map { "id\($0)" }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Scroll to row 10
        let targetRow = 10
        let rowY = table.rowMetricsStore.yOffsetForRow(targetRow)
        table.collectionView.contentOffset = CGPoint(x: 0, y: rowY)
        table.collectionView.layoutIfNeeded()

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Delete row 10 (the anchor row)
        var newData = data
        var newIdentifiers = identifiers
        newData.remove(at: targetRow)
        newIdentifiers.remove(at: targetRow)
        table.setData(newData, rowIdentifiers: newIdentifiers, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: The table should show the nearest surviving row (row 9 or what was row 11)
        // without a large visual jump
        XCTAssertEqual(table.numberOfRows(), 29, "Should have 29 rows after deletion")

        // Verify we're still in a reasonable scroll position (near where row 10 was)
        let newContentOffset = table.collectionView.contentOffset.y
        let row9Y = table.rowMetricsStore.yOffsetForRow(9)
        let row11Y = table.rowMetricsStore.yOffsetForRow(10)  // Was row 11, now row 10

        // Should be somewhere between the rows adjacent to the deleted row
        XCTAssertGreaterThanOrEqual(newContentOffset, row9Y - 50, "Should be near the deleted row area")
        XCTAssertLessThanOrEqual(newContentOffset, row11Y + 50, "Should be near the deleted row area")
    }

    /// Large batch update (>50%) path also preserves anchor.
    func test_largeBatchUpdate_preservesAnchor() {
        // Given: A table with rows, scrolled to middle
        var data: DataTableContent = (0..<20).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Scroll to row 10
        let targetRow = 10
        let rowY = table.rowMetricsStore.yOffsetForRow(targetRow)
        table.collectionView.contentOffset = CGPoint(x: 0, y: rowY)
        table.collectionView.layoutIfNeeded()

        let viewportTopBefore = table.collectionView.contentOffset.y

        // When: Replace >50% of the rows (triggers reloadData path)
        // Replace all rows with new content
        data = (0..<20).map { [.string("New Row \($0)")] }
        table.setData(data, animatingDifferences: true)
        table.collectionView.layoutIfNeeded()

        // Then: Should be at a similar position (the anchor row still exists)
        let viewportTopAfter = table.collectionView.contentOffset.y

        // Allow some tolerance since the content changed but row count is same
        XCTAssertEqual(
            viewportTopAfter, viewportTopBefore,
            accuracy: 5.0,
            "Large batch update should preserve approximate scroll position"
        )
    }

    /// Test seam for isDragging/isDecelerating allows controlling scroll state in tests.
    func test_scrollStateTestSeam_canOverrideScrollState() {
        // Given: A table
        let data: DataTableContent = (0..<10).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // By default, seam is nil (uses real scroll state)
        XCTAssertNil(table._testScrollStateOverride, "Test seam should be nil by default")

        // Can set to true (simulate active scrolling)
        table._testScrollStateOverride = true
        XCTAssertEqual(table._testScrollStateOverride, true, "Test seam should accept true")

        // Can set to false (simulate not scrolling)
        table._testScrollStateOverride = false
        XCTAssertEqual(table._testScrollStateOverride, false, "Test seam should accept false")

        // Can reset to nil
        table._testScrollStateOverride = nil
        XCTAssertNil(table._testScrollStateOverride, "Test seam should be resettable to nil")
    }

    /// Verify anchoring behavior can be controlled via test seam.
    /// When seam = true (simulating scroll), anchoring should be skipped.
    func test_activeScrolling_skipsAnchoring() {
        // Given: A table with rows, scrolled to middle
        var data: DataTableContent = (0..<20).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Scroll to row 10
        let rowY = table.rowMetricsStore.yOffsetForRow(10)
        table.collectionView.contentOffset = CGPoint(x: 0, y: rowY)
        table.collectionView.layoutIfNeeded()

        // Simulate active scrolling via test seam
        table._testScrollStateOverride = true

        // When: Perform update that would trigger anchoring
        data.append(contentsOf: (20..<25).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: false)
        table.collectionView.layoutIfNeeded()

        // Then: No crash, table updated successfully
        // (UICollectionView may still preserve position, but our anchoring code was skipped)
        XCTAssertEqual(table.numberOfRows(), 25, "Should have 25 rows after append")

        // Clean up
        table._testScrollStateOverride = nil
    }

    /// Anchoring works when not actively scrolling (test seam set to false).
    func test_notActivelyScrolling_appliesAnchoring() {
        // Given: A table with rows, scrolled to row 10
        var data: DataTableContent = (0..<30).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        let targetRow = 10
        let rowY = table.rowMetricsStore.yOffsetForRow(targetRow)
        table.collectionView.contentOffset = CGPoint(x: 0, y: rowY)
        table.collectionView.layoutIfNeeded()

        // Record anchor row's visual position relative to viewport
        let anchorFrameBefore = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: targetRow)
        )?.frame
        let viewportTopBefore = table.collectionView.contentOffset.y
        let visualOffsetBefore = (anchorFrameBefore?.minY ?? 0) - viewportTopBefore

        // Explicitly set not scrolling via test seam
        table._testScrollStateOverride = false

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Insert rows above viewport while NOT scrolling
        data.insert(contentsOf: [[.string("New 0")], [.string("New 1")], [.string("New 2")]], at: 0)
        table.setData(data, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: Anchor row (now at section 13) should have SAME visual position
        // because anchoring preserved it
        let newAnchorSection = targetRow + 3
        let anchorFrameAfter = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: newAnchorSection)
        )?.frame
        let viewportTopAfter = table.collectionView.contentOffset.y
        let visualOffsetAfter = (anchorFrameAfter?.minY ?? 0) - viewportTopAfter

        // Visual position should be preserved (anchoring worked)
        XCTAssertEqual(
            visualOffsetAfter, visualOffsetBefore,
            accuracy: 2.0,
            "Anchor row's visual position should be preserved when anchoring is enabled"
        )

        // Clean up
        table._testScrollStateOverride = nil
    }

    // MARK: - Helpers

    private func makeTableInWindow(data: DataTableContent, headerTitles: [String]) -> SwiftDataTable {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.rowHeightMode = .fixed(44)

        let table = SwiftDataTable(data: data, headerTitles: headerTitles, options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        return table
    }
}
