//
//  DataTableValueConvertibleTests.swift
//  SwiftDataTablesTests
//
//  Tests for DataTableValueConvertible protocol and conformances.
//

import XCTest
@testable import SwiftDataTables

final class DataTableValueConvertibleTests: XCTestCase {

    // MARK: - String Conversion

    func test_string_convertsToStringValue() {
        let value = "Hello"
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string("Hello"))
    }

    func test_emptyString_convertsToEmptyStringValue() {
        let value = ""
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string(""))
    }

    // MARK: - Int Conversion

    func test_int_convertsToIntValue() {
        let value = 42
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .int(42))
    }

    func test_negativeInt_convertsToIntValue() {
        let value = -100
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .int(-100))
    }

    func test_zeroInt_convertsToIntValue() {
        let value = 0
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .int(0))
    }

    // MARK: - Float Conversion

    func test_float_convertsToFloatValue() {
        let value: Float = 3.14
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .float(3.14))
    }

    func test_negativeFloat_convertsToFloatValue() {
        let value: Float = -2.5
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .float(-2.5))
    }

    // MARK: - Double Conversion

    func test_double_convertsToDoubleValue() {
        let value: Double = 3.14159265359
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .double(3.14159265359))
    }

    func test_negativeDouble_convertsToDoubleValue() {
        let value: Double = -99.99
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .double(-99.99))
    }

    // MARK: - Optional Conversion

    func test_optionalString_withValue_convertsToStringValue() {
        let value: String? = "Test"
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string("Test"))
    }

    func test_optionalString_withNil_convertsToEmptyString() {
        let value: String? = nil
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string(""))
    }

    func test_optionalInt_withValue_convertsToIntValue() {
        let value: Int? = 123
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .int(123))
    }

    func test_optionalInt_withNil_convertsToEmptyString() {
        let value: Int? = nil
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string(""))
    }

    func test_optionalDouble_withValue_convertsToDoubleValue() {
        let value: Double? = 1.5
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .double(1.5))
    }

    func test_optionalDouble_withNil_convertsToEmptyString() {
        let value: Double? = nil
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string(""))
    }

    // MARK: - DataTableValueType Self-Conformance

    func test_dataTableValueType_string_returnsSelf() {
        let value = DataTableValueType.string("Hello")
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .string("Hello"))
    }

    func test_dataTableValueType_int_returnsSelf() {
        let value = DataTableValueType.int(42)
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .int(42))
    }

    func test_dataTableValueType_double_returnsSelf() {
        let value = DataTableValueType.double(3.14)
        let result = value.asDataTableValue()

        XCTAssertEqual(result, .double(3.14))
    }
}
