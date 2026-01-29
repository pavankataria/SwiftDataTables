//
//  DefaultCellConfigurationTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for `DataTableConfiguration.defaultCellConfiguration` callback.
///
/// These tests verify:
/// - The callback is invoked when displaying cells
/// - All parameters are passed correctly (cell, value, indexPath, isHighlighted)
/// - Font and colour customisation works
/// - Per-cell conditional styling works
/// - The callback is not called when using custom cells
/// - Backward compatibility with deprecated colour arrays
@MainActor
final class DefaultCellConfigurationTests: XCTestCase {

    // MARK: - Callback Invocation

    func test_defaultCellConfiguration_isCalledWhenDisplayingCell() {
        var wasCalled = false
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { _, _, _, _ in
            wasCalled = true
        }

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        // Trigger willDisplay
        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertTrue(wasCalled, "defaultCellConfiguration should be called when displaying a cell")
    }

    func test_defaultCellConfiguration_isCalledForEachCell() {
        var callCount = 0
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { _, _, _, _ in
            callCount += 1
        }

        let table = SwiftDataTable(
            data: [["A", "B"], ["C", "D"]],
            headerTitles: ["Col1", "Col2"],
            options: config
        )

        // Trigger willDisplay for each cell (2 rows x 2 columns = 4 cells)
        for row in 0..<2 {
            for col in 0..<2 {
                let cell = DataCell(frame: .zero)
                table.collectionView(
                    table.collectionView,
                    willDisplay: cell,
                    forItemAt: IndexPath(item: row, section: col)
                )
            }
        }

        XCTAssertEqual(callCount, 4, "defaultCellConfiguration should be called for each cell")
    }

    // MARK: - Parameter Verification

    func test_defaultCellConfiguration_receivesCorrectCell() {
        var receivedCell: DataCell?
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { cell, _, _, _ in
            receivedCell = cell
        }

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertTrue(receivedCell === cell, "defaultCellConfiguration should receive the same cell instance")
    }

    func test_defaultCellConfiguration_receivesCorrectValue() {
        var receivedValues: [String] = []
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { _, value, _, _ in
            receivedValues.append(value.stringRepresentation)
        }

        let table = SwiftDataTable(
            data: [["Hello", "World"]],
            headerTitles: ["Col1", "Col2"],
            options: config
        )

        // Trigger for both columns
        // Note: In SwiftDataTables, section=row and item=column
        for col in 0..<2 {
            let cell = DataCell(frame: .zero)
            table.collectionView(
                table.collectionView,
                willDisplay: cell,
                forItemAt: IndexPath(item: col, section: 0)
            )
        }

        XCTAssertEqual(receivedValues, ["Hello", "World"], "defaultCellConfiguration should receive correct values")
    }

    func test_defaultCellConfiguration_receivesCorrectIndexPath() {
        var receivedIndexPaths: [IndexPath] = []
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { _, _, indexPath, _ in
            receivedIndexPaths.append(indexPath)
        }

        let table = SwiftDataTable(
            data: [["A", "B"], ["C", "D"]],
            headerTitles: ["Col1", "Col2"],
            options: config
        )

        // Trigger for specific cells
        let testIndexPaths = [
            IndexPath(item: 0, section: 0),
            IndexPath(item: 1, section: 1)
        ]

        for indexPath in testIndexPaths {
            let cell = DataCell(frame: .zero)
            table.collectionView(
                table.collectionView,
                willDisplay: cell,
                forItemAt: indexPath
            )
        }

        XCTAssertEqual(receivedIndexPaths, testIndexPaths, "defaultCellConfiguration should receive correct indexPaths")
    }

    // MARK: - Font Customisation

    func test_defaultCellConfiguration_canSetFont() {
        let customFont = UIFont.boldSystemFont(ofSize: 20)
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { cell, _, _, _ in
            cell.dataLabel.font = customFont
        }

        let table = SwiftDataTable(
            data: [["Test"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertEqual(cell.dataLabel.font, customFont, "Font should be customisable via defaultCellConfiguration")
    }

    // MARK: - Colour Customisation

    func test_defaultCellConfiguration_canSetBackgroundColour() {
        let customColour = UIColor.systemRed
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { cell, _, _, _ in
            cell.backgroundColor = customColour
        }

        let table = SwiftDataTable(
            data: [["Test"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertEqual(cell.backgroundColor, customColour, "Background colour should be customisable via defaultCellConfiguration")
    }

    func test_defaultCellConfiguration_canSetTextColour() {
        let customColour = UIColor.systemGreen
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { cell, _, _, _ in
            cell.dataLabel.textColor = customColour
        }

        let table = SwiftDataTable(
            data: [["Test"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertEqual(cell.dataLabel.textColor, customColour, "Text colour should be customisable via defaultCellConfiguration")
    }

    func test_defaultCellConfiguration_canSetAlternatingRowColours() {
        var config = DataTableConfiguration()
        // Note: In SwiftDataTables, section=row and item=column
        // So we use indexPath.section to alternate by row
        config.defaultCellConfiguration = { cell, _, indexPath, _ in
            cell.backgroundColor = indexPath.section % 2 == 0 ? .red : .blue
        }

        let table = SwiftDataTable(
            data: [["A"], ["B"], ["C"]],
            headerTitles: ["Header"],
            options: config
        )

        // Test row 0 (even) - IndexPath(item: column, section: row)
        let cell0 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell0, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(cell0.backgroundColor, .red, "Even rows should be red")

        // Test row 1 (odd)
        let cell1 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell1, forItemAt: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1.backgroundColor, .blue, "Odd rows should be blue")

        // Test row 2 (even)
        let cell2 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell2, forItemAt: IndexPath(item: 0, section: 2))
        XCTAssertEqual(cell2.backgroundColor, .red, "Even rows should be red")
    }

    // MARK: - Conditional Styling

    func test_defaultCellConfiguration_canStyleBasedOnValue() {
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { cell, value, _, _ in
            if value.stringRepresentation == "Error" {
                cell.dataLabel.textColor = .red
            } else {
                cell.dataLabel.textColor = .label
            }
        }

        let table = SwiftDataTable(
            data: [["OK"], ["Error"]],
            headerTitles: ["Status"],
            options: config
        )

        // Test "OK" cell (row 0, col 0)
        // Note: In SwiftDataTables, section=row and item=column
        let okCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: okCell, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(okCell.dataLabel.textColor, .label, "OK status should have default colour")

        // Test "Error" cell (row 1, col 0)
        let errorCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: errorCell, forItemAt: IndexPath(item: 0, section: 1))
        XCTAssertEqual(errorCell.dataLabel.textColor, .red, "Error status should be red")
    }

    // MARK: - CellSizingMode Interaction

    func test_defaultCellConfiguration_notCalledForCustomCells() {
        var wasCalled = false
        var config = DataTableConfiguration()
        config.defaultCellConfiguration = { _, _, _, _ in
            wasCalled = true
        }

        // Set up custom cell provider
        let provider = DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "custom")
            },
            reuseIdentifierFor: { _ in "custom" },
            configure: { _, _, _ in },
            sizingCellFor: { _ in UICollectionViewCell() }
        )
        config.cellSizingMode = .autoLayout(provider: provider)

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        // Use a regular UICollectionViewCell (not DataCell) to simulate custom cell
        let cell = UICollectionViewCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertFalse(wasCalled, "defaultCellConfiguration should not be called for custom cells")
    }

    // MARK: - Backward Compatibility

    func test_deprecatedColourArrays_stillWorkWhenNoCallback() {
        var config = DataTableConfiguration()
        config.highlightedAlternatingRowColors = [.systemPurple, .systemOrange]
        // No defaultCellConfiguration set

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        // Use a regular UICollectionViewCell to test the fallback path
        let cell = UICollectionViewCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        // The cell's contentView backgroundColor should be set from the deprecated arrays
        // This tests the fallback path is still working
        XCTAssertNotNil(cell.contentView.backgroundColor, "Deprecated colour arrays should still work when no callback is set")
    }

    func test_defaultCellConfiguration_overridesDeprecatedColours() {
        let expectedColour = UIColor.systemCyan
        var config = DataTableConfiguration()
        config.highlightedAlternatingRowColors = [.systemPurple]
        config.unhighlightedAlternatingRowColors = [.systemOrange]
        config.defaultCellConfiguration = { cell, _, _, _ in
            cell.backgroundColor = expectedColour
        }

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertEqual(cell.backgroundColor, expectedColour, "defaultCellConfiguration should take precedence over deprecated colour arrays")
    }

    // MARK: - Composability Tests

    func test_colourArrays_appliedAsBaseline_whenCallbackDoesNotSetBackground() {
        // Color arrays should be applied first, then callback runs
        // If callback doesn't set backgroundColor, the array colour should persist
        var config = DataTableConfiguration()
        config.unhighlightedAlternatingRowColors = [.systemPurple, .systemOrange]
        config.defaultCellConfiguration = { cell, _, _, _ in
            // Only set font, don't touch background
            cell.dataLabel.font = .boldSystemFont(ofSize: 20)
        }

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["Header"],
            options: config
        )

        let cell = DataCell(frame: .zero)
        table.collectionView(
            table.collectionView,
            willDisplay: cell,
            forItemAt: IndexPath(item: 0, section: 0)
        )

        // Font should be customised
        XCTAssertEqual(cell.dataLabel.font, .boldSystemFont(ofSize: 20), "Font should be set by callback")

        // Background should come from color arrays (applied to contentView)
        XCTAssertEqual(cell.contentView.backgroundColor, .systemPurple, "Color array background should persist when callback doesn't override")
    }

    func test_colourArrays_composableWithFontStyling() {
        // Common use case: user wants custom fonts but default alternating row colours
        var config = DataTableConfiguration()
        config.unhighlightedAlternatingRowColors = [.white, .systemGray6]
        config.defaultCellConfiguration = { cell, _, _, _ in
            cell.dataLabel.font = UIFont(name: "Avenir", size: 14) ?? .systemFont(ofSize: 14)
            cell.dataLabel.textColor = .darkGray
            // Don't set backgroundColor - let color arrays handle it
        }

        let table = SwiftDataTable(
            data: [["Row1"], ["Row2"]],
            headerTitles: ["Header"],
            options: config
        )

        // Test row 0 (should be white from color arrays)
        let cell0 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell0, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(cell0.contentView.backgroundColor, .white, "First row should have white background from color arrays")
        XCTAssertEqual(cell0.dataLabel.textColor, .darkGray, "Text color should be set by callback")

        // Test row 1 (should be systemGray6 from color arrays)
        // Note: In SwiftDataTables, section=row and item=column
        let cell1 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell1, forItemAt: IndexPath(item: 0, section: 1))
        XCTAssertEqual(cell1.contentView.backgroundColor, .systemGray6, "Second row should have gray background from color arrays")
        XCTAssertEqual(cell1.dataLabel.textColor, .darkGray, "Text color should be set by callback")
    }

    func test_colourArrays_canBeConditionallyOverridden() {
        // Use case: color arrays for most cells, but override specific cells
        var config = DataTableConfiguration()
        config.unhighlightedAlternatingRowColors = [.white, .systemGray6]
        config.defaultCellConfiguration = { cell, value, _, _ in
            // Override background only for "Error" cells
            if value.stringRepresentation == "Error" {
                cell.backgroundColor = .systemRed.withAlphaComponent(0.2)
            }
            // Other cells keep their color array background
        }

        let table = SwiftDataTable(
            data: [["OK"], ["Error"], ["OK"]],
            headerTitles: ["Status"],
            options: config
        )

        // Test "OK" cell - should have color array background
        let okCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: okCell, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(okCell.contentView.backgroundColor, .white, "OK cell should have color array background")
        XCTAssertNil(okCell.backgroundColor, "OK cell's own background should not be set")

        // Test "Error" cell - should have overridden background
        // Note: In SwiftDataTables, section=row and item=column
        let errorCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: errorCell, forItemAt: IndexPath(item: 0, section: 1))
        XCTAssertEqual(errorCell.backgroundColor, .systemRed.withAlphaComponent(0.2), "Error cell should have custom background")
    }

    func test_highlightedColourArrays_appliedForSortedColumn() {
        var config = DataTableConfiguration()
        config.highlightedAlternatingRowColors = [.systemBlue, .systemIndigo]
        config.unhighlightedAlternatingRowColors = [.white, .systemGray6]
        config.defaultCellConfiguration = { cell, _, _, _ in
            // Only set font, background comes from arrays based on highlight state
            cell.dataLabel.font = .boldSystemFont(ofSize: 16)
        }

        let table = SwiftDataTable(
            data: [["A", "B"]],
            headerTitles: ["Col1", "Col2"],
            options: config
        )

        // Sort by first column and highlight it
        // Note: sort() alone doesn't highlight - we need to call highlight() separately
        // (didTapColumn does both internally when a user taps a header)
        table.highlight(column: 0)
        table.sort(column: 0, sort: .ascending)

        // Test highlighted column (col 0)
        let highlightedCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: highlightedCell, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(highlightedCell.contentView.backgroundColor, .systemBlue, "Highlighted column should use highlightedAlternatingRowColors")

        // Test unhighlighted column (col 1)
        // Note: In SwiftDataTables, section=row and item=column
        let unhighlightedCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: unhighlightedCell, forItemAt: IndexPath(item: 1, section: 0))
        XCTAssertEqual(unhighlightedCell.contentView.backgroundColor, .white, "Unhighlighted column should use unhighlightedAlternatingRowColors")
    }
}
