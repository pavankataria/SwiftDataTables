//
//  DataTableTypedSortingIntegrationTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 29/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Integration tests for typed sorting in SwiftDataTable.
///
/// These tests verify:
/// - Sorting uses `compare` closure when available
/// - Sorting falls back to `DataTableValueType` when no comparator
/// - Auto-disable sorting indicators for header-only columns
/// - End-to-end sorting with formatted values
@MainActor
final class DataTableTypedSortingIntegrationTests: XCTestCase {

    // MARK: - Test Model

    private struct Product: Identifiable {
        let id: Int
        let name: String
        let price: Double
    }

    private let products = [
        Product(id: 1, name: "Widget", price: 29.99),
        Product(id: 2, name: "Gadget", price: 9.99),
        Product(id: 3, name: "Appliance", price: 199.99)
    ]

    // MARK: - Typed Sorting Tests

    func test_sortByTypedValue_notByFormattedString() {
        // Price column: displays "$29.99" but sorts by 29.99
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),
            .init("Price", \.price) { "$\(String(format: "%.2f", $0))" }
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Tap price column to sort ascending
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // After ascending sort by price: 9.99, 29.99, 199.99
        // So order should be: Gadget, Widget, Appliance
        let firstRowName = dataTable.currentRowViewModels[0][0]
        let lastRowName = dataTable.currentRowViewModels[2][0]

        XCTAssertEqual(firstRowName.stringRepresentation, "Gadget")
        XCTAssertEqual(lastRowName.stringRepresentation, "Appliance")
    }

    func test_sortBySortedByKeypath() {
        struct Person: Identifiable {
            let id = UUID()
            let firstName: String
            let lastName: String
        }
        let people = [
            Person(firstName: "Alice", lastName: "Zimmerman"),
            Person(firstName: "Bob", lastName: "Adams"),
            Person(firstName: "Charlie", lastName: "Miller")
        ]

        let columns: [DataTableColumn<Person>] = [
            .init("Name", sortedBy: \.lastName) { "\($0.firstName) \($0.lastName)" }
        ]

        let dataTable = SwiftDataTable(
            data: people,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Sort ascending by lastName
        dataTable.didTapColumn(index: IndexPath(index: 0))

        // Adams < Miller < Zimmerman
        let names = dataTable.currentRowViewModels.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Bob Adams", "Charlie Miller", "Alice Zimmerman"])
    }

    func test_sortWithComputedValue() {
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),
            .init("Value", sortedBy: { $0.price * 10 }) { "x10: $\(String(format: "%.2f", $0.price * 10))" }
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Sort by computed value (price * 10)
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // 99.9 < 299.9 < 1999.9
        let firstRow = dataTable.currentRowViewModels[0][0].stringRepresentation
        XCTAssertEqual(firstRow, "Gadget")
    }

    // MARK: - Fallback Tests

    func test_sortFallsBackToDataTableValueType_whenNoComparator() {
        // Using regular keypath column (no compare closure)
        let columns: [DataTableColumn<Product>] = [
            .init("Price", \.price)  // No format, uses DataTableValueType
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        dataTable.didTapColumn(index: IndexPath(index: 0))

        // Should still sort numerically via DataTableValueType
        let prices = dataTable.currentRowViewModels.map { $0[0].data }
        XCTAssertEqual(prices, [.double(9.99), .double(29.99), .double(199.99)])
    }

    // MARK: - Auto-Disable Sort Indicator Tests

    func test_headerOnlyColumn_hasSortTypeHidden() {
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),
            .init("Actions")  // Header-only
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)
        XCTAssertEqual(dataTable.headerViewModels[1].sortType, .hidden)
    }

    func test_headerOnlyColumn_tappingDoesNotSort() {
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),
            .init("Actions")
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        let initialOrder = dataTable.currentRowViewModels.map { $0[0].data.stringRepresentation }

        // Tap header-only column
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // Order should not change
        let afterOrder = dataTable.currentRowViewModels.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(initialOrder, afterOrder)
    }

    // MARK: - isColumnSortable Override Tests

    func test_isColumnSortable_overridesAutoDisable() {
        var config = DataTableConfiguration()
        config.isColumnSortable = { _ in true }  // Force all columns sortable

        let columns: [DataTableColumn<Product>] = [
            .init("Actions")  // Header-only but forced sortable
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: config,
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // User override should take precedence
        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)
    }

    func test_isColumnSortable_canDisableSortableColumn() {
        var config = DataTableConfiguration()
        config.isColumnSortable = { _ in false }  // Force all columns non-sortable

        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name)  // Has extract but forced non-sortable
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: config,
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        XCTAssertEqual(dataTable.headerViewModels[0].sortType, .hidden)
    }

    // MARK: - Descending Sort Tests

    func test_sortDescending_withTypedComparator() {
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),
            .init("Price", \.price) { "$\(String(format: "%.2f", $0))" }
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // First tap: ascending
        dataTable.didTapColumn(index: IndexPath(index: 1))
        // Second tap: descending
        dataTable.didTapColumn(index: IndexPath(index: 1))

        // After descending sort by price: 199.99, 29.99, 9.99
        let firstRowName = dataTable.currentRowViewModels[0][0]
        let lastRowName = dataTable.currentRowViewModels[2][0]

        XCTAssertEqual(firstRowName.stringRepresentation, "Appliance")
        XCTAssertEqual(lastRowName.stringRepresentation, "Gadget")
    }

    // MARK: - Mixed Column Types Tests

    func test_mixedColumnTypes_sortCorrectly() {
        let columns: [DataTableColumn<Product>] = [
            .init("Name", \.name),                                    // KeyPath - no compare
            .init("Price", \.price) { "$\($0)" },                     // KeyPath + format - has compare
            .init("Actions")                                          // Header only - no compare, no extract
        ]

        let dataTable = SwiftDataTable(
            data: products,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Name column should be sortable (has extract)
        XCTAssertNotEqual(dataTable.headerViewModels[0].sortType, .hidden)

        // Price column should be sortable (has extract and compare)
        XCTAssertNotEqual(dataTable.headerViewModels[1].sortType, .hidden)

        // Actions column should NOT be sortable (no extract, no compare)
        XCTAssertEqual(dataTable.headerViewModels[2].sortType, .hidden)
    }

    // MARK: - Custom Comparator Tests

    func test_customComparator_sortsCaseInsensitive() {
        struct Item: Identifiable {
            let id = UUID()
            let name: String
        }

        let items = [
            Item(name: "banana"),
            Item(name: "Apple"),
            Item(name: "Cherry")
        ]

        let columns: [DataTableColumn<Item>] = [
            .init("Name", sortedBy: { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name)
            }) { $0.name }
        ]

        let dataTable = SwiftDataTable(
            data: items,
            columns: columns,
            options: DataTableConfiguration(),
            frame: CGRect(x: 0, y: 0, width: 400, height: 400)
        )

        // Sort ascending
        dataTable.didTapColumn(index: IndexPath(index: 0))

        // Case-insensitive: Apple < banana < Cherry
        let names = dataTable.currentRowViewModels.map { $0[0].data.stringRepresentation }
        XCTAssertEqual(names, ["Apple", "banana", "Cherry"])
    }
}
