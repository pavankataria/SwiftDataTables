//
//  DataTableColumnTests.swift
//  SwiftDataTablesTests
//
//  Tests for DataTableColumn type-safe column definitions.
//

import XCTest
@testable import SwiftDataTables

final class DataTableColumnTests: XCTestCase {

    // MARK: - Test Model

    private struct TestPerson: Identifiable {
        let id: Int
        let name: String
        let age: Int
        let score: Double
        let nickname: String?
    }

    // MARK: - Header Tests

    func test_column_storesHeader() {
        let column = DataTableColumn<TestPerson>("Name", \.name)

        XCTAssertEqual(column.header, "Name")
    }

    func test_headerOnlyColumn_storesHeader() {
        let column = DataTableColumn<TestPerson>("Custom")

        XCTAssertEqual(column.header, "Custom")
    }

    // MARK: - KeyPath Extraction Tests

    func test_column_withStringKeyPath_extractsValue() {
        let column = DataTableColumn<TestPerson>("Name", \.name)
        let person = TestPerson(id: 1, name: "Alice", age: 30, score: 95.5, nickname: nil)

        let result = column.extract?(person)

        XCTAssertEqual(result, .string("Alice"))
    }

    func test_column_withIntKeyPath_extractsValue() {
        let column = DataTableColumn<TestPerson>("Age", \.age)
        let person = TestPerson(id: 1, name: "Bob", age: 25, score: 88.0, nickname: nil)

        let result = column.extract?(person)

        XCTAssertEqual(result, .int(25))
    }

    func test_column_withDoubleKeyPath_extractsValue() {
        let column = DataTableColumn<TestPerson>("Score", \.score)
        let person = TestPerson(id: 1, name: "Charlie", age: 35, score: 92.5, nickname: nil)

        let result = column.extract?(person)

        XCTAssertEqual(result, .double(92.5))
    }

    func test_column_withOptionalKeyPath_extractsValue_whenPresent() {
        let column = DataTableColumn<TestPerson>("Nickname", \.nickname)
        let person = TestPerson(id: 1, name: "Diana", age: 28, score: 90.0, nickname: "Di")

        let result = column.extract?(person)

        XCTAssertEqual(result, .string("Di"))
    }

    func test_column_withOptionalKeyPath_extractsEmptyString_whenNil() {
        let column = DataTableColumn<TestPerson>("Nickname", \.nickname)
        let person = TestPerson(id: 1, name: "Eve", age: 32, score: 85.0, nickname: nil)

        let result = column.extract?(person)

        XCTAssertEqual(result, .string(""))
    }

    // MARK: - Custom Extraction Tests

    func test_column_withCustomExtract_usesProvidedClosure() {
        let column = DataTableColumn<TestPerson>("Full Info") { person in
            .string("\(person.name) (\(person.age))")
        }
        let person = TestPerson(id: 1, name: "Frank", age: 40, score: 80.0, nickname: nil)

        let result = column.extract?(person)

        XCTAssertEqual(result, .string("Frank (40)"))
    }

    func test_column_withCustomExtract_canReturnDifferentTypes() {
        let doubleAgeColumn = DataTableColumn<TestPerson>("Double Age") { person in
            .int(person.age * 2)
        }
        let person = TestPerson(id: 1, name: "Grace", age: 20, score: 75.0, nickname: nil)

        let result = doubleAgeColumn.extract?(person)

        XCTAssertEqual(result, .int(40))
    }

    // MARK: - Header-Only Column Tests

    func test_headerOnlyColumn_hasNilExtract() {
        let column = DataTableColumn<TestPerson>("Actions")

        XCTAssertNil(column.extract)
    }

    // MARK: - Multiple Columns Tests

    func test_multipleColumns_extractCorrectValues() {
        let columns: [DataTableColumn<TestPerson>] = [
            .init("ID", \.id),
            .init("Name", \.name),
            .init("Age", \.age),
            .init("Score", \.score)
        ]
        let person = TestPerson(id: 42, name: "Henry", age: 45, score: 99.9, nickname: "Hank")

        let values = columns.compactMap { $0.extract?(person) }

        XCTAssertEqual(values.count, 4)
        XCTAssertEqual(values[0], .int(42))
        XCTAssertEqual(values[1], .string("Henry"))
        XCTAssertEqual(values[2], .int(45))
        XCTAssertEqual(values[3], .double(99.9))
    }

    func test_columns_headersExtractedCorrectly() {
        let columns: [DataTableColumn<TestPerson>] = [
            .init("ID", \.id),
            .init("Name", \.name),
            .init("Age", \.age)
        ]

        let headers = columns.map { $0.header }

        XCTAssertEqual(headers, ["ID", "Name", "Age"])
    }
}
