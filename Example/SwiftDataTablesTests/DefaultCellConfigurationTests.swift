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
        for col in 0..<2 {
            let cell = DataCell(frame: .zero)
            table.collectionView(
                table.collectionView,
                willDisplay: cell,
                forItemAt: IndexPath(item: 0, section: col)
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
        config.defaultCellConfiguration = { cell, _, indexPath, _ in
            cell.backgroundColor = indexPath.item % 2 == 0 ? .red : .blue
        }

        let table = SwiftDataTable(
            data: [["A"], ["B"], ["C"]],
            headerTitles: ["Header"],
            options: config
        )

        // Test row 0 (even)
        let cell0 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell0, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(cell0.backgroundColor, .red, "Even rows should be red")

        // Test row 1 (odd)
        let cell1 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell1, forItemAt: IndexPath(item: 1, section: 0))
        XCTAssertEqual(cell1.backgroundColor, .blue, "Odd rows should be blue")

        // Test row 2 (even)
        let cell2 = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: cell2, forItemAt: IndexPath(item: 2, section: 0))
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

        // Test "OK" cell
        let okCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: okCell, forItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(okCell.dataLabel.textColor, .label, "OK status should have default colour")

        // Test "Error" cell
        let errorCell = DataCell(frame: .zero)
        table.collectionView(table.collectionView, willDisplay: errorCell, forItemAt: IndexPath(item: 1, section: 0))
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
}
