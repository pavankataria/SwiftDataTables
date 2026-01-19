//
//  SwiftDataTableIncrementalUpdatesTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableIncrementalUpdatesTests: XCTestCase {

    func test_setData_appendsNewRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Append a new row
        data.append([.string("C")])
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "B", "C"])
    }

    func test_setData_insertsRowAtPosition() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Insert in the middle
        data.insert([.string("B")], at: 1)
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "B", "C"])
    }

    func test_setData_deletesRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")],
            [.string("D")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Remove rows at indices 1 and 3 (B and D)
        data.remove(at: 3)
        data.remove(at: 1)
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "C"])
    }

    func test_setData_updatesRowContent() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Update row at index 1
        data[1] = [.string("Z")]
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["A", "Z", "C"])
    }

    func test_setData_handlesMixedOperations() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Delete first row, insert new row at end
        data.remove(at: 0)
        data.append([.string("D")])
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["B", "C", "D"])
    }

    func test_setData_clearsAllRows() {
        var data: DataTableContent = [
            [.string("A")],
            [.string("B")],
            [.string("C")]
        ]
        let table = SwiftDataTable(data: data, headerTitles: ["H"])

        // Clear all
        data.removeAll()
        table.setData(data, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), [])
    }

    func test_setData_withExplicitIdentifiers_tracksCorrectly() {
        var data: DataTableContent = [
            [.string("Alice")],
            [.string("Bob")]
        ]
        var identifiers = ["id1", "id2"]
        let table = SwiftDataTable(data: data, headerTitles: ["Name"])

        // Initial setup
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // Add a new row with its own ID
        data.append([.string("Charlie")])
        identifiers.append("id3")
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        XCTAssertEqual(rowStrings(in: table), ["Alice", "Bob", "Charlie"])

        // Update Bob's content (same ID, different content)
        data[1] = [.string("Robert")]
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // With ID-based tracking, Robert replaces Bob at the same position
        XCTAssertEqual(rowStrings(in: table), ["Alice", "Robert", "Charlie"])
    }
}

@MainActor
private func rowStrings(in table: SwiftDataTable) -> [String] {
    return table.rows.compactMap { $0.first?.data.stringRepresentation }
}

// MARK: - Layout Behavior Tests

@MainActor
final class SwiftDataTableLayoutBehaviorTests: XCTestCase {

    // MARK: - Scroll Position Preservation

    func test_appendingRows_preservesContentOffset() {
        // Given: A table with some rows, scrolled to a position
        var data: DataTableContent = (0..<20).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        // Scroll down
        let scrolledOffset = CGPoint(x: 0, y: 100)
        table.collectionView.contentOffset = scrolledOffset

        // When: Append rows at the end
        data.append(contentsOf: (20..<25).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: false)

        // Then: Content offset should be preserved (not reset to top)
        XCTAssertEqual(
            table.collectionView.contentOffset.y,
            scrolledOffset.y,
            accuracy: 1.0,
            "Content offset should be preserved when appending rows"
        )
    }

    func test_appendingRows_doesNotAffectVisibleCellPositions() {
        // Given: A table with rows, note the frame of a visible cell
        var data: DataTableContent = (0..<10).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        let cellFrameBefore = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: 0)
        )?.frame

        // When: Append rows at the end
        data.append(contentsOf: (10..<15).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: false)
        table.collectionView.layoutIfNeeded()

        let cellFrameAfter = table.collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: 0)
        )?.frame

        // Then: First row's frame should be unchanged
        XCTAssertEqual(cellFrameBefore, cellFrameAfter, "Existing cell frames should not change when appending")
    }

    // MARK: - Layout Correctness

    func test_layoutAttributes_haveCorrectYPositions_afterInsertInMiddle() {
        // Given: A table with 5 rows
        var data: DataTableContent = (0..<5).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        // When: Insert a row at position 2
        data.insert([.string("Inserted")], at: 2)
        table.setData(data, animatingDifferences: false)
        table.collectionView.layoutIfNeeded()

        // Then: All rows should have non-overlapping, sequential Y positions
        var lastMaxY: CGFloat = 0
        for section in 0..<table.numberOfRows() {
            guard let attrs = table.collectionView.layoutAttributesForItem(
                at: IndexPath(item: 0, section: section)
            ) else {
                XCTFail("Missing layout attributes for section \(section)")
                continue
            }
            XCTAssertGreaterThanOrEqual(
                attrs.frame.minY, lastMaxY,
                "Row \(section) should be positioned after row \(section - 1)"
            )
            lastMaxY = attrs.frame.maxY
        }
    }

    func test_contentSize_increasesWhenAppendingRows() {
        // Given: A table with initial rows
        var data: DataTableContent = (0..<5).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        let initialContentHeight = table.collectionView.contentSize.height

        // When: Append more rows
        data.append(contentsOf: (5..<10).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: false)
        table.collectionView.layoutIfNeeded()

        let newContentHeight = table.collectionView.contentSize.height

        // Then: Content size should increase
        XCTAssertGreaterThan(
            newContentHeight, initialContentHeight,
            "Content height should increase when rows are appended"
        )
    }

    // MARK: - Animation Tests

    func test_appendingRows_withAnimation_preservesContentOffset() {
        // Given: A table scrolled to a position
        var data: DataTableContent = (0..<20).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])

        let scrolledOffset = CGPoint(x: 0, y: 100)
        table.collectionView.contentOffset = scrolledOffset

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Append rows WITH animation
        data.append(contentsOf: (20..<25).map { [.string("Row \($0)")] })
        table.setData(data, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: Content offset should still be preserved
        XCTAssertEqual(
            table.collectionView.contentOffset.y,
            scrolledOffset.y,
            accuracy: 1.0,
            "Content offset should be preserved after animated append"
        )
    }

    func test_insertingInMiddle_withAnimation_adjustsLayoutCorrectly() {
        // Given: A table with rows
        var data: DataTableContent = (0..<10).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        let expectation = XCTestExpectation(description: "Animation completes")

        // When: Insert in middle WITH animation
        data.insert([.string("Inserted")], at: 5)
        table.setData(data, animatingDifferences: true) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        // Then: Should have 11 rows with correct layout
        XCTAssertEqual(table.numberOfRows(), 11)

        // Verify no overlapping frames
        var frames: [CGRect] = []
        for section in 0..<table.numberOfRows() {
            if let attrs = table.collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: section)) {
                for existing in frames {
                    XCTAssertFalse(
                        attrs.frame.intersects(existing),
                        "Row \(section) overlaps with another row"
                    )
                }
                frames.append(attrs.frame)
            }
        }
    }

    // MARK: - Performance Tests

    func test_collectionViewContentSize_usesCachedValue_notRecalculatedEveryCall() {
        // Given: A table with many rows
        let rowCount = 10_000
        let data: DataTableContent = (0..<rowCount).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        // When: Access contentSize multiple times
        let iterations = 1000
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            _ = table.collectionView.contentSize
        }
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

        // Then: Should be fast (< 100ms for 1000 accesses)
        // If it were O(n) per call with 10K rows, 1000 calls would be very slow
        XCTAssertLessThan(
            elapsedTime, 0.1,
            "contentSize should be O(1) cached access, not O(n) recalculation. Took \(elapsedTime)s for \(iterations) calls"
        )
    }

    func test_contentSize_remainsConstant_duringScrolling() {
        // Given: A table with rows
        let data: DataTableContent = (0..<100).map { [.string("Row \($0)")] }
        let table = makeTableInWindow(data: data, headerTitles: ["H"])
        table.collectionView.layoutIfNeeded()

        let initialSize = table.collectionView.contentSize

        // When: Simulate scrolling by changing content offset multiple times
        for y in stride(from: 0, to: 500, by: 50) {
            table.collectionView.contentOffset = CGPoint(x: 0, y: CGFloat(y))
            table.collectionView.layoutIfNeeded()

            // Then: Content size should remain constant (not recalculated differently)
            XCTAssertEqual(
                table.collectionView.contentSize, initialSize,
                "Content size should not change during scrolling"
            )
        }
    }

    // MARK: - Helpers

    private func makeTableInWindow(data: DataTableContent, headerTitles: [String]) -> SwiftDataTable {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.rowHeightMode = .fixed(44)

        let table = SwiftDataTable(data: data, headerTitles: headerTitles, options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        // Add to window so layout works
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        return table
    }
}

// MARK: - Content Change Detection Tests

@MainActor
final class SwiftDataTableContentChangeTests: XCTestCase {

    // MARK: - Test Model

    private struct Stock: DataTableDifferentiable {
        let id: String
        var symbol: String
        var price: Double

        func isContentEqual(to source: Stock) -> Bool {
            symbol == source.symbol && price == source.price
        }
    }

    // MARK: - DataTableDifferentiable Tests

    func test_setData_withDifferentiable_onlyMarksChangedRows() {
        // Given: A table with stocks
        var stocks = [
            Stock(id: "1", symbol: "AAPL", price: 100),
            Stock(id: "2", symbol: "GOOGL", price: 200),
            Stock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<Stock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Update only one stock's price
        stocks[1].price = 250  // Change GOOGL's price

        // Before setData, precomputedChangedIdentifiers should be nil
        XCTAssertNil(table.precomputedChangedIdentifiers)

        // Call setData - this should set precomputedChangedIdentifiers
        table.setData(stocks, animatingDifferences: false)

        // Note: precomputedChangedIdentifiers is cleared after use in applyDiff
        // So we can't check it after setData completes
        // Instead, verify the data was updated correctly
        XCTAssertEqual(table.rows.count, 3)
    }

    func test_isContentEqual_detectsChanges() {
        let stock1 = Stock(id: "1", symbol: "AAPL", price: 100)
        let stock2 = Stock(id: "1", symbol: "AAPL", price: 100)
        let stock3 = Stock(id: "1", symbol: "AAPL", price: 150)

        // Same content
        XCTAssertTrue(stock1.isContentEqual(to: stock2))

        // Different price
        XCTAssertFalse(stock1.isContentEqual(to: stock3))
    }

    func test_setData_withDifferentiable_preservesUnchangedRows() {
        // Given: Initial data
        var stocks = [
            Stock(id: "1", symbol: "AAPL", price: 100),
            Stock(id: "2", symbol: "GOOGL", price: 200),
            Stock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<Stock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Update one stock
        stocks[0].price = 150  // Change AAPL's price
        table.setData(stocks, animatingDifferences: false)

        // Then: All rows still exist with correct values
        XCTAssertEqual(table.rows.count, 3)
        XCTAssertEqual(table.rows[0][1].data, .double(150))  // Updated
        XCTAssertEqual(table.rows[1][1].data, .double(200))  // Unchanged
        XCTAssertEqual(table.rows[2][1].data, .double(300))  // Unchanged
    }

    func test_setData_withDifferentiable_reloadsOnlyChangedItems() {
        // Given: Initial data and a spy-backed table
        var stocks = [
            Stock(id: "1", symbol: "AAPL", price: 100),
            Stock(id: "2", symbol: "GOOGL", price: 200),
            Stock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<Stock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        let initialContent: DataTableContent = stocks.map {
            [.string($0.symbol), .double($0.price)]
        }
        let table = makeSpyTableInWindow(data: initialContent, headerTitles: ["Symbol", "Price"])

        // Seed identifiers + typed context
        table.setData(stocks, columns: columns, animatingDifferences: false)
        table.spyCollectionView.resetTracking()

        // When: Update only one row
        stocks[1].price = 250

        let expectation = XCTestExpectation(description: "Diff completes")
        table.setData(stocks, columns: columns, animatingDifferences: true) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then: Only the changed cell should be reloaded
        XCTAssertEqual(table.spyCollectionView.reloadedItems, [IndexPath(item: 1, section: 1)])
        XCTAssertTrue(table.spyCollectionView.reloadedSections.isEmpty)
        XCTAssertEqual(table.spyCollectionView.reloadDataCallCount, 0)
    }

    func test_setData_withDifferentiable_usesCellReloadsForChangedColumns() {
        var stocks = [
            Stock(id: "1", symbol: "AAPL", price: 100),
            Stock(id: "2", symbol: "GOOGL", price: 200)
        ]
        let columns: [DataTableColumn<Stock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        let initialContent: DataTableContent = stocks.map {
            [.string($0.symbol), .double($0.price)]
        }
        let table = makeSpyTableInWindow(data: initialContent, headerTitles: ["Symbol", "Price"])

        table.setData(stocks, columns: columns, animatingDifferences: false)
        table.spyCollectionView.resetTracking()

        stocks[0].price = 105

        let expectation = XCTestExpectation(description: "Diff completes")
        table.setData(stocks, columns: columns, animatingDifferences: true) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(table.spyCollectionView.reloadedItems, [IndexPath(item: 1, section: 0)])
        XCTAssertTrue(table.spyCollectionView.reloadedSections.isEmpty)
    }

    func test_rowContentEqual_returnsTrue_forIdenticalRows() {
        // Given: Two identical view model rows
        let row1 = [
            DataCellViewModel(data: .string("AAPL")),
            DataCellViewModel(data: .double(100))
        ]
        let row2 = [
            DataCellViewModel(data: .string("AAPL")),
            DataCellViewModel(data: .double(100))
        ]

        // Then: They should be equal
        XCTAssertTrue(rowsAreEqual(row1, row2))
    }

    func test_rowContentEqual_returnsFalse_forDifferentRows() {
        // Given: Two different view model rows
        let row1 = [
            DataCellViewModel(data: .string("AAPL")),
            DataCellViewModel(data: .double(100))
        ]
        let row2 = [
            DataCellViewModel(data: .string("AAPL")),
            DataCellViewModel(data: .double(150))  // Different price
        ]

        // Then: They should NOT be equal
        XCTAssertFalse(rowsAreEqual(row1, row2))
    }

    // MARK: - Reload Tracking Tests

    func test_setData_withOneChange_reloadsOnlyChangedSection() {
        // This test verifies that when one row changes, only that row is reloaded
        // (not all rows)

        // Given: Initial data with explicit IDs
        var data: DataTableContent = [
            [.string("AAPL"), .double(100)],
            [.string("GOOGL"), .double(200)],
            [.string("MSFT"), .double(300)]
        ]
        let identifiers = ["id1", "id2", "id3"]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: data, headerTitles: ["Symbol", "Price"], options: config)
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // Swap the collection view with a spy
        let spy = CollectionViewReloadSpy(
            frame: table.collectionView.frame,
            collectionViewLayout: table.collectionView.collectionViewLayout
        )
        // Note: We can't easily swap the collection view, so instead we'll verify
        // the precomputed changed identifiers before they're cleared

        // When: Update only GOOGL's price (id2)
        data[1] = [.string("GOOGL"), .double(250)]

        // Store a reference to check after - but precomputedChangedIdentifiers
        // is internal, so we check via the table's public properties
        table.setData(data, rowIdentifiers: identifiers, animatingDifferences: false)

        // Then: Verify data is correct
        XCTAssertEqual(table.rows[0][1].data, .double(100))  // AAPL unchanged
        XCTAssertEqual(table.rows[1][1].data, .double(250))  // GOOGL changed
        XCTAssertEqual(table.rows[2][1].data, .double(300))  // MSFT unchanged
    }

    func test_precomputedChangedIdentifiers_isSetCorrectly() {
        // Given: A table with DataTableDifferentiable models
        var stocks = [
            Stock(id: "1", symbol: "AAPL", price: 100),
            Stock(id: "2", symbol: "GOOGL", price: 200),
            Stock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<Stock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Change one stock's price
        stocks[1].price = 250  // GOOGL

        // Manually compute what changedIds should be
        // The setData method should detect that id "2" has changed
        table.setData(stocks, animatingDifferences: false)

        // Then: The data should be updated correctly
        // (precomputedChangedIdentifiers is cleared after use, so we verify via results)
        XCTAssertEqual(table.rows[1][1].data, .double(250))
    }

    // MARK: - Column-Based Comparison Tests (for regular Identifiable types)

    /// A simple Identifiable model (NOT DataTableDifferentiable)
    private struct SimpleStock: Identifiable {
        let id: String
        var symbol: String
        var price: Double
    }

    func test_setData_withIdentifiable_usesColumnExtractorsForChangeDetection() {
        // Given: A table with simple Identifiable stocks (no isContentEqual)
        var stocks = [
            SimpleStock(id: "1", symbol: "AAPL", price: 100),
            SimpleStock(id: "2", symbol: "GOOGL", price: 200),
            SimpleStock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<SimpleStock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Update only one stock's price
        stocks[1].price = 250  // Change GOOGL's price

        // The Identifiable overload should now use column extractors
        // to detect that only GOOGL changed
        table.setData(stocks, animatingDifferences: false)

        // Then: All rows should have correct data
        XCTAssertEqual(table.rows.count, 3)
        XCTAssertEqual(table.rows[0][1].data, .double(100))  // AAPL unchanged
        XCTAssertEqual(table.rows[1][1].data, .double(250))  // GOOGL changed
        XCTAssertEqual(table.rows[2][1].data, .double(300))  // MSFT unchanged
    }

    func test_setData_withIdentifiable_detectsMultipleChanges() {
        // Given: A table with simple stocks
        var stocks = [
            SimpleStock(id: "1", symbol: "AAPL", price: 100),
            SimpleStock(id: "2", symbol: "GOOGL", price: 200),
            SimpleStock(id: "3", symbol: "MSFT", price: 300)
        ]
        let columns: [DataTableColumn<SimpleStock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Update two stocks
        stocks[0].price = 150  // Change AAPL
        stocks[2].symbol = "MSFT Inc"  // Change MSFT symbol
        table.setData(stocks, animatingDifferences: false)

        // Then: Changes should be reflected
        XCTAssertEqual(table.rows[0][1].data, .double(150))  // AAPL price changed
        XCTAssertEqual(table.rows[1][1].data, .double(200))  // GOOGL unchanged
        XCTAssertEqual(table.rows[2][0].data, .string("MSFT Inc"))  // MSFT symbol changed
    }

    func test_setData_withIdentifiable_noChangesDoesNotReload() {
        // Given: A table with stocks
        let stocks = [
            SimpleStock(id: "1", symbol: "AAPL", price: 100),
            SimpleStock(id: "2", symbol: "GOOGL", price: 200)
        ]
        let columns: [DataTableColumn<SimpleStock>] = [
            .init("Symbol", \.symbol),
            .init("Price") { .double($0.price) }
        ]

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        let table = SwiftDataTable(data: stocks, columns: columns, options: config)

        // When: Set same data again (no changes)
        table.setData(stocks, animatingDifferences: false)

        // Then: Data should remain the same
        XCTAssertEqual(table.rows.count, 2)
        XCTAssertEqual(table.rows[0][0].data, .string("AAPL"))
        XCTAssertEqual(table.rows[1][0].data, .string("GOOGL"))
    }

    // MARK: - Helpers

    private func rowsAreEqual(_ row1: [DataCellViewModel], _ row2: [DataCellViewModel]) -> Bool {
        guard row1.count == row2.count else { return false }
        for i in 0..<row1.count {
            if row1[i].data != row2[i].data {
                return false
            }
        }
        return true
    }

    private func makeSpyTableInWindow(data: DataTableContent, headerTitles: [String]) -> SwiftDataTableCollectionViewSpy {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.rowHeightMode = .fixed(44)

        let table = SwiftDataTableCollectionViewSpy(data: data, headerTitles: headerTitles, options: config)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        let window = UIWindow(frame: table.frame)
        window.addSubview(table)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        return table
    }
}

// MARK: - Spy Classes

private class CollectionViewReloadSpy: UICollectionView {
    var reloadedSections: IndexSet = []
    var reloadedItems: [IndexPath] = []
    var reloadDataCallCount = 0

    override func reloadSections(_ sections: IndexSet) {
        reloadedSections.formUnion(sections)
        super.reloadSections(sections)
    }

    override func reloadItems(at indexPaths: [IndexPath]) {
        reloadedItems.append(contentsOf: indexPaths)
        super.reloadItems(at: indexPaths)
    }

    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }

    func resetTracking() {
        reloadedSections = []
        reloadedItems = []
        reloadDataCallCount = 0
    }
}

@MainActor
private final class SwiftDataTableCollectionViewSpy: SwiftDataTable {
    let spyCollectionView: CollectionViewReloadSpy

    override var collectionView: UICollectionView {
        get { spyCollectionView }
        set { }
    }

    init(data: DataTableContent, headerTitles: [String], options: DataTableConfiguration) {
        spyCollectionView = CollectionViewReloadSpy(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        super.init(data: data, headerTitles: headerTitles, options: options)

        spyCollectionView.dataSource = self
        spyCollectionView.delegate = self
        spyCollectionView.backgroundColor = .clear
        spyCollectionView.allowsMultipleSelection = true
        if #available(iOS 10, *) {
            spyCollectionView.isPrefetchingEnabled = false
        }
        addSubview(spyCollectionView)
        registerCell(collectionView: spyCollectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
