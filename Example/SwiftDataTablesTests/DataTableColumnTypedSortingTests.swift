//
//  DataTableColumnTypedSortingTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 29/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
@testable import SwiftDataTables

/// Tests for typed sorting architecture in `DataTableColumn<T>`.
///
/// These tests verify:
/// - The `compare` property exists and stores comparators
/// - New initializers create correct extract/compare closures
/// - Existing initializers remain unchanged (non-breaking)
/// - Auto-disable sorting for header-only columns
final class DataTableColumnTypedSortingTests: XCTestCase {

    // MARK: - Test Model

    private struct Product: Identifiable {
        let id: Int
        let name: String
        let price: Double
        let quantity: Int
        let createdAt: Date
        let category: String
    }

    private let sampleProduct = Product(
        id: 1,
        name: "Widget",
        price: 29.99,
        quantity: 100,
        createdAt: Date(timeIntervalSince1970: 1000000),
        category: "Electronics"
    )

    private let cheaperProduct = Product(
        id: 2,
        name: "Gadget",
        price: 9.99,
        quantity: 50,
        createdAt: Date(timeIntervalSince1970: 500000),
        category: "Electronics"
    )

    private let expensiveProduct = Product(
        id: 3,
        name: "Appliance",
        price: 199.99,
        quantity: 10,
        createdAt: Date(timeIntervalSince1970: 2000000),
        category: "Home"
    )

    // MARK: - Compare Property Exists Tests

    func test_column_hasCompareProperty() {
        let column = DataTableColumn<Product>("Name", \.name)
        // Property exists (may be nil for existing initializers)
        _ = column.compare
    }

    func test_keypathColumn_hasNilCompare() {
        let column = DataTableColumn<Product>("Name", \.name)
        XCTAssertNil(column.compare)
    }

    func test_closureColumn_hasNilCompare() {
        let column = DataTableColumn<Product>("Info") { "\($0.name)" }
        XCTAssertNil(column.compare)
    }

    func test_headerOnlyColumn_hasNilCompare() {
        let column = DataTableColumn<Product>("Actions")
        XCTAssertNil(column.compare)
    }

    // MARK: - KeyPath + Format Initializer Tests

    func test_keypathWithFormat_extractsFormattedString() {
        let column = DataTableColumn<Product>("Price", \.price) { "$\(String(format: "%.2f", $0))" }

        let result = column.extract?(sampleProduct)
        XCTAssertEqual(result, .string("$29.99"))
    }

    func test_keypathWithFormat_comparesTypedValues() {
        let column = DataTableColumn<Product>("Price", \.price) { "$\(String(format: "%.2f", $0))" }

        // Cheaper < Sample
        let result1 = column.compare?(cheaperProduct, sampleProduct)
        XCTAssertEqual(result1, .orderedAscending)

        // Expensive > Sample
        let result2 = column.compare?(expensiveProduct, sampleProduct)
        XCTAssertEqual(result2, .orderedDescending)

        // Same product
        let result3 = column.compare?(sampleProduct, sampleProduct)
        XCTAssertEqual(result3, .orderedSame)
    }

    func test_keypathWithFormat_intKeyPath() {
        let column = DataTableColumn<Product>("Qty", \.quantity) { "\($0) units" }

        let result = column.extract?(sampleProduct)
        XCTAssertEqual(result, .string("100 units"))

        // Compare: 50 < 100
        let comparison = column.compare?(cheaperProduct, sampleProduct)
        XCTAssertEqual(comparison, .orderedAscending)
    }

    func test_keypathWithFormat_dateKeyPath() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        let column = DataTableColumn<Product>("Created", \.createdAt) { formatter.string(from: $0) }

        XCTAssertNotNil(column.extract?(sampleProduct))

        // Earlier date < Later date
        let comparison = column.compare?(cheaperProduct, sampleProduct)
        XCTAssertEqual(comparison, .orderedAscending)
    }

    // MARK: - SortedBy KeyPath + Display Tests

    func test_sortedByKeypath_extractsDisplayString() {
        let column = DataTableColumn<Product>("Product", sortedBy: \.price) {
            "\($0.name) ($\(String(format: "%.2f", $0.price)))"
        }

        let result = column.extract?(sampleProduct)
        XCTAssertEqual(result, .string("Widget ($29.99)"))
    }

    func test_sortedByKeypath_comparesTypedValues() {
        let column = DataTableColumn<Product>("Product", sortedBy: \.price) {
            "\($0.name) ($\(String(format: "%.2f", $0.price)))"
        }

        // Sort by price, not by display string
        let result = column.compare?(cheaperProduct, sampleProduct)
        XCTAssertEqual(result, .orderedAscending)
    }

    func test_sortedByKeypath_differentSortThanDisplay() {
        // Display "Alice Smith" but sort by lastName
        struct Person {
            let firstName: String
            let lastName: String
        }

        let alice = Person(firstName: "Alice", lastName: "Zimmerman")
        let bob = Person(firstName: "Bob", lastName: "Adams")

        let column = DataTableColumn<Person>("Name", sortedBy: \.lastName) {
            "\($0.firstName) \($0.lastName)"
        }

        // Display shows full name
        XCTAssertEqual(column.extract?(alice), .string("Alice Zimmerman"))

        // But sorts by lastName: Adams < Zimmerman
        let result = column.compare?(bob, alice)
        XCTAssertEqual(result, .orderedAscending)
    }

    // MARK: - SortedBy Extractor + Display Tests

    func test_sortedByExtractor_extractsDisplayString() {
        let column = DataTableColumn<Product>("Total", sortedBy: { $0.price * Double($0.quantity) }) {
            "$\(String(format: "%.2f", $0.price * Double($0.quantity)))"
        }

        let result = column.extract?(sampleProduct)
        XCTAssertEqual(result, .string("$2999.00"))
    }

    func test_sortedByExtractor_comparesComputedValues() {
        // Sample: 29.99 * 100 = 2999
        // Cheaper: 9.99 * 50 = 499.5
        // Expensive: 199.99 * 10 = 1999.9
        let column = DataTableColumn<Product>("Total", sortedBy: { $0.price * Double($0.quantity) }) {
            "$\(String(format: "%.2f", $0.price * Double($0.quantity)))"
        }

        // Cheaper (499.5) < Expensive (1999.9)
        let result1 = column.compare?(cheaperProduct, expensiveProduct)
        XCTAssertEqual(result1, .orderedAscending)

        // Sample (2999) > Expensive (1999.9)
        let result2 = column.compare?(sampleProduct, expensiveProduct)
        XCTAssertEqual(result2, .orderedDescending)
    }

    func test_sortedByExtractor_stringLength() {
        let column = DataTableColumn<Product>("Name", sortedBy: { $0.name.count }) { $0.name }

        // "Widget" (6) vs "Gadget" (6)
        let result1 = column.compare?(sampleProduct, cheaperProduct)
        XCTAssertEqual(result1, .orderedSame)

        // "Appliance" (9) > "Widget" (6)
        let result2 = column.compare?(expensiveProduct, sampleProduct)
        XCTAssertEqual(result2, .orderedDescending)
    }

    // MARK: - SortedBy Comparator + Display Tests

    func test_sortedByComparator_extractsDisplayString() {
        let column = DataTableColumn<Product>("Name", sortedBy: { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        }) { $0.name }

        let result = column.extract?(sampleProduct)
        XCTAssertEqual(result, .string("Widget"))
    }

    func test_sortedByComparator_usesCustomComparison() {
        let column = DataTableColumn<Product>("Name", sortedBy: { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name)
        }) { $0.name }

        // "Appliance" < "Gadget" < "Widget"
        let result1 = column.compare?(expensiveProduct, cheaperProduct)
        XCTAssertEqual(result1, .orderedAscending)

        let result2 = column.compare?(sampleProduct, cheaperProduct)
        XCTAssertEqual(result2, .orderedDescending)
    }

    func test_sortedByComparator_nullsLast() {
        struct Item {
            let name: String
            let dueDate: Date?
        }

        let withDate = Item(name: "A", dueDate: Date())
        let withoutDate = Item(name: "B", dueDate: nil)

        let column = DataTableColumn<Item>("Due", sortedBy: { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedDescending  // nil goes last
            case (_, nil): return .orderedAscending
            case (let a?, let b?): return a.compare(b)
            }
        }) { $0.dueDate?.description ?? "No date" }

        // Item with date comes before item without
        let result = column.compare?(withDate, withoutDate)
        XCTAssertEqual(result, .orderedAscending)
    }

    // MARK: - Non-Breaking: Existing Initializers Unchanged

    func test_existingKeypathInit_stillWorks() {
        let column = DataTableColumn<Product>("Name", \.name)

        XCTAssertEqual(column.header, "Name")
        XCTAssertEqual(column.extract?(sampleProduct), .string("Widget"))
        XCTAssertNil(column.compare)
    }

    func test_existingClosureInit_stillWorks() {
        let column = DataTableColumn<Product>("Info") { "\($0.name) - \($0.category)" }

        XCTAssertEqual(column.header, "Info")
        XCTAssertEqual(column.extract?(sampleProduct), .string("Widget - Electronics"))
        XCTAssertNil(column.compare)
    }

    func test_existingExplicitTypeInit_stillWorks() {
        let column = DataTableColumn<Product>("Score") { .int(Int($0.price)) }

        XCTAssertEqual(column.header, "Score")
        XCTAssertEqual(column.extract?(sampleProduct), .int(29))
        XCTAssertNil(column.compare)
    }

    func test_existingHeaderOnlyInit_stillWorks() {
        let column = DataTableColumn<Product>("Actions")

        XCTAssertEqual(column.header, "Actions")
        XCTAssertNil(column.extract)
        XCTAssertNil(column.compare)
    }

    // MARK: - Auto-Disable Sorting Tests

    func test_headerOnlyColumn_isNotSortable() {
        let column = DataTableColumn<Product>("Actions")
        XCTAssertFalse(column.isSortable)
    }

    func test_keypathColumn_isSortable() {
        let column = DataTableColumn<Product>("Name", \.name)
        XCTAssertTrue(column.isSortable)
    }

    func test_closureColumn_isSortable() {
        let column = DataTableColumn<Product>("Info") { $0.name }
        XCTAssertTrue(column.isSortable)
    }

    func test_sortedByColumn_isSortable() {
        let column = DataTableColumn<Product>("Total", sortedBy: \.price) { "$\($0.price)" }
        XCTAssertTrue(column.isSortable)
    }

    func test_comparatorColumn_isSortable() {
        let column = DataTableColumn<Product>("Name", sortedBy: { lhs, rhs in
            lhs.name.compare(rhs.name)
        }) { $0.name }
        XCTAssertTrue(column.isSortable)
    }

    // MARK: - Closure Parameter Type Verification Tests

    // These tests verify that closures receive the CORRECT parameter type.
    // This catches bugs where we might accidentally pass Row instead of Value or vice versa.

    func test_keypathWithFormat_formatClosureReceivesTypedValue_notRow() {
        // The format closure should receive the PROPERTY VALUE (Double), not the Row (Product)
        var receivedValue: Double?

        let column = DataTableColumn<Product>("Price", \.price) { (value: Double) -> String in
            receivedValue = value
            return "$\(value)"
        }

        _ = column.extract?(sampleProduct)

        // Verify we received the property value (29.99), not some default
        XCTAssertEqual(receivedValue, 29.99, "Format closure should receive the property value")
    }

    func test_keypathWithFormat_formatClosureReceivesInt() {
        var receivedValue: Int?

        let column = DataTableColumn<Product>("Qty", \.quantity) { (value: Int) -> String in
            receivedValue = value
            return "\(value) units"
        }

        _ = column.extract?(sampleProduct)

        XCTAssertEqual(receivedValue, 100, "Format closure should receive Int property value")
    }

    func test_keypathWithFormat_formatClosureReceivesDate() {
        var receivedDate: Date?

        let column = DataTableColumn<Product>("Created", \.createdAt) { (date: Date) -> String in
            receivedDate = date
            return date.description
        }

        _ = column.extract?(sampleProduct)

        XCTAssertEqual(receivedDate, sampleProduct.createdAt, "Format closure should receive Date property value")
    }

    func test_sortedByKeypath_displayClosureReceivesFullRow() {
        // The display closure should receive the FULL ROW (Product), not just a property
        var receivedProduct: Product?

        let column = DataTableColumn<Product>("Info", sortedBy: \.price) { (row: Product) -> String in
            receivedProduct = row
            return row.name
        }

        _ = column.extract?(sampleProduct)

        // Verify we received the full product with all its properties
        XCTAssertEqual(receivedProduct?.id, sampleProduct.id, "Display closure should receive full row")
        XCTAssertEqual(receivedProduct?.name, sampleProduct.name, "Display closure should receive full row")
        XCTAssertEqual(receivedProduct?.price, sampleProduct.price, "Display closure should receive full row")
    }

    func test_sortedByExtractor_extractorReceivesFullRow() {
        var extractorReceivedProducts: [Product] = []

        let column = DataTableColumn<Product>("Total", sortedBy: { (row: Product) -> Double in
            extractorReceivedProducts.append(row)
            return row.price * Double(row.quantity)
        }) { _ in "display" }

        // Trigger compare to invoke the extractor (called for both lhs and rhs)
        _ = column.compare?(sampleProduct, cheaperProduct)

        // Extractor should be called for both products being compared
        XCTAssertEqual(extractorReceivedProducts.count, 2, "Extractor should be called for both rows in comparison")
        XCTAssertTrue(extractorReceivedProducts.contains { $0.id == sampleProduct.id }, "Extractor should receive sampleProduct")
        XCTAssertTrue(extractorReceivedProducts.contains { $0.id == cheaperProduct.id }, "Extractor should receive cheaperProduct")
    }

    func test_sortedByExtractor_displayClosureReceivesFullRow() {
        var displayReceivedProduct: Product?

        let column = DataTableColumn<Product>("Total", sortedBy: { $0.price * Double($0.quantity) }) { (row: Product) -> String in
            displayReceivedProduct = row
            return "$\(row.price)"
        }

        _ = column.extract?(sampleProduct)

        XCTAssertEqual(displayReceivedProduct?.id, sampleProduct.id, "Display closure should receive full row")
        XCTAssertEqual(displayReceivedProduct?.name, sampleProduct.name, "Display closure should receive full row")
    }

    func test_sortedByComparator_comparatorReceivesTwoRows() {
        var comparatorLhs: Product?
        var comparatorRhs: Product?

        let column = DataTableColumn<Product>("Name", sortedBy: { (lhs: Product, rhs: Product) -> ComparisonResult in
            comparatorLhs = lhs
            comparatorRhs = rhs
            return .orderedSame
        }) { $0.name }

        _ = column.compare?(sampleProduct, cheaperProduct)

        XCTAssertEqual(comparatorLhs?.id, sampleProduct.id, "Comparator should receive lhs row")
        XCTAssertEqual(comparatorRhs?.id, cheaperProduct.id, "Comparator should receive rhs row")
    }

    func test_sortedByComparator_displayClosureReceivesFullRow() {
        var displayReceivedProduct: Product?

        let column = DataTableColumn<Product>("Name", sortedBy: { lhs, rhs in
            lhs.name.compare(rhs.name)
        }) { (row: Product) -> String in
            displayReceivedProduct = row
            return row.name
        }

        _ = column.extract?(sampleProduct)

        XCTAssertEqual(displayReceivedProduct?.id, sampleProduct.id, "Display closure should receive full row")
    }

    // MARK: - Closure Type Compile-Time Safety Tests

    // These tests verify the API prevents common type mismatches at compile time.
    // If the test compiles, it means the types are correctly enforced.

    func test_keypathWithFormat_compileTimeSafety_doubleProperty() {
        // This should compile: price is Double, format receives Double
        let _: DataTableColumn<Product> = .init("Price", \.price) { (value: Double) -> String in
            String(format: "%.2f", value)
        }
    }

    func test_keypathWithFormat_compileTimeSafety_intProperty() {
        // This should compile: quantity is Int, format receives Int
        let _: DataTableColumn<Product> = .init("Qty", \.quantity) { (value: Int) -> String in
            "\(value)"
        }
    }

    func test_keypathWithFormat_compileTimeSafety_stringProperty() {
        // This should compile: name is String, format receives String
        let _: DataTableColumn<Product> = .init("Name", \.name) { (value: String) -> String in
            value.uppercased()
        }
    }

    func test_sortedByKeypath_compileTimeSafety_displayReceivesRow() {
        // This should compile: display closure receives Product (the row type)
        let _: DataTableColumn<Product> = .init("Info", sortedBy: \.price) { (row: Product) -> String in
            "\(row.name): $\(row.price)"
        }
    }

    func test_sortedByExtractor_compileTimeSafety_bothReceiveRow() {
        // This should compile: both closures receive Product
        let _: DataTableColumn<Product> = .init("Total",
            sortedBy: { (row: Product) -> Double in row.price * Double(row.quantity) }
        ) { (row: Product) -> String in
            "$\(row.price * Double(row.quantity))"
        }
    }

    func test_sortedByComparator_compileTimeSafety_comparatorReceivesTwoRows() {
        // This should compile: comparator receives (Product, Product)
        let _: DataTableColumn<Product> = .init("Name",
            sortedBy: { (lhs: Product, rhs: Product) -> ComparisonResult in
                lhs.name.compare(rhs.name)
            }
        ) { (row: Product) -> String in
            row.name
        }
    }

    // MARK: - Edge Cases

    func test_keypathWithFormat_sameValueReturnsDifferentFormattedStrings() {
        // Verify that even with same-value products, the format closure is called correctly
        let product1 = Product(id: 1, name: "A", price: 10.0, quantity: 1, createdAt: Date(), category: "X")
        let product2 = Product(id: 2, name: "B", price: 10.0, quantity: 2, createdAt: Date(), category: "Y")

        let column = DataTableColumn<Product>("Price", \.price) { "$\(String(format: "%.2f", $0))" }

        let result1 = column.extract?(product1)
        let result2 = column.extract?(product2)

        // Both should format the same price
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result1, .string("$10.00"))
    }

    func test_sortedByKeypath_accessesCorrectProperty() {
        // Ensure the comparator uses the sort property, not the display value
        struct Person: Identifiable {
            let id = UUID()
            let displayName: String  // "Alice"
            let sortKey: Int         // 3 (alphabetical rank)
        }

        let alice = Person(displayName: "Alice", sortKey: 3)
        let bob = Person(displayName: "Bob", sortKey: 1)
        let charlie = Person(displayName: "Charlie", sortKey: 2)

        let column = DataTableColumn<Person>("Name", sortedBy: \.sortKey) { $0.displayName }

        // Sort by sortKey: Bob (1) < Charlie (2) < Alice (3)
        XCTAssertEqual(column.compare?(bob, alice), .orderedAscending)     // 1 < 3
        XCTAssertEqual(column.compare?(charlie, alice), .orderedAscending) // 2 < 3
        XCTAssertEqual(column.compare?(bob, charlie), .orderedAscending)   // 1 < 2

        // But display shows displayName
        XCTAssertEqual(column.extract?(alice), .string("Alice"))
        XCTAssertEqual(column.extract?(bob), .string("Bob"))
    }
}
