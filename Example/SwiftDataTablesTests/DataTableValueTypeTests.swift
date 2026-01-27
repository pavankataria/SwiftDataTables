//
//  DataTableValueTypeTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
@testable import SwiftDataTables

/// Tests for the `DataTableValueType` enum that represents cell values.
///
/// These tests verify:
/// - Initialization from various Swift types (Int, Float, Double, String)
/// - String representation for display
/// - Comparison and equality for sorting
/// - Array sorting behavior (ascending and descending)
class DataTableValueTypeTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withInt_createsIntType() {
        let value = DataTableValueType(42)
        XCTAssertEqual(value, .int(42))
    }

    func test_init_withFloat_createsFloatType() {
        let value = DataTableValueType(Float(3.14))
        XCTAssertEqual(value, .float(3.14))
    }

    func test_init_withDouble_createsDoubleType() {
        let value = DataTableValueType(Double(3.14159))
        XCTAssertEqual(value, .double(3.14159))
    }

    func test_init_withString_createsStringType() {
        let value = DataTableValueType("Hello")
        XCTAssertEqual(value, .string("Hello"))
    }

    func test_init_withNumericString_createsIntType() {
        let value = DataTableValueType("42")
        XCTAssertEqual(value, .int(42))
    }

    func test_init_withNonNumericString_createsStringType() {
        let value = DataTableValueType("abc123")
        XCTAssertEqual(value, .string("abc123"))
    }

    func test_init_withEmptyString_createsEmptyStringType() {
        let value = DataTableValueType("")
        XCTAssertEqual(value, .string(""))
    }

    func test_init_withNegativeInt_createsNegativeIntType() {
        let value = DataTableValueType(-100)
        XCTAssertEqual(value, .int(-100))
    }

    func test_init_withZero_createsZeroIntType() {
        let value = DataTableValueType(0)
        XCTAssertEqual(value, .int(0))
    }

    // MARK: - String Representation Tests

    func test_stringRepresentation_forInt_returnsCorrectString() {
        let value = DataTableValueType.int(42)
        XCTAssertEqual(value.stringRepresentation, "42")
    }

    func test_stringRepresentation_forFloat_returnsCorrectString() {
        let value = DataTableValueType.float(3.14)
        XCTAssertTrue(value.stringRepresentation.hasPrefix("3.14"))
    }

    func test_stringRepresentation_forDouble_returnsCorrectString() {
        let value = DataTableValueType.double(3.14159)
        XCTAssertTrue(value.stringRepresentation.hasPrefix("3.14159"))
    }

    func test_stringRepresentation_forString_returnsCorrectString() {
        let value = DataTableValueType.string("Hello World")
        XCTAssertEqual(value.stringRepresentation, "Hello World")
    }

    func test_stringRepresentation_forNegativeNumber_includesMinus() {
        let value = DataTableValueType.int(-42)
        XCTAssertEqual(value.stringRepresentation, "-42")
    }

    // MARK: - Comparison Tests (Critical for Sorting)

    func test_equality_sameInts_areEqual() {
        let a = DataTableValueType.int(42)
        let b = DataTableValueType.int(42)
        XCTAssertEqual(a, b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(a > b)
    }

    func test_comparison_differentInts_ascending() {
        let a = DataTableValueType.int(1)
        let b = DataTableValueType.int(2)
        XCTAssertTrue(a < b)
        XCTAssertTrue(b > a)
        XCTAssertNotEqual(a, b)
    }

    func test_comparison_negativeAndPositiveInts() {
        let negative = DataTableValueType.int(-10)
        let positive = DataTableValueType.int(10)
        XCTAssertTrue(negative < positive)
    }

    func test_equality_sameStrings_areEqual() {
        let a = DataTableValueType.string("Apple")
        let b = DataTableValueType.string("Apple")
        XCTAssertEqual(a, b)
    }

    func test_comparison_differentStrings_alphabetical() {
        let a = DataTableValueType.string("Apple")
        let b = DataTableValueType.string("Banana")
        XCTAssertTrue(a < b)
        XCTAssertTrue(b > a)
    }

    func test_comparison_strings_caseSensitive() {
        let lowercase = DataTableValueType.string("apple")
        let uppercase = DataTableValueType.string("Apple")
        // In ASCII, uppercase comes before lowercase
        XCTAssertTrue(uppercase < lowercase)
    }

    func test_equality_sameFloats_areEqual() {
        let a = DataTableValueType.float(3.14)
        let b = DataTableValueType.float(3.14)
        XCTAssertEqual(a, b)
    }

    func test_comparison_differentFloats() {
        let a = DataTableValueType.float(1.5)
        let b = DataTableValueType.float(2.5)
        XCTAssertTrue(a < b)
    }

    func test_equality_sameDoubles_areEqual() {
        let a = DataTableValueType.double(3.14159)
        let b = DataTableValueType.double(3.14159)
        XCTAssertEqual(a, b)
    }

    func test_comparison_differentDoubles() {
        let a = DataTableValueType.double(1.5)
        let b = DataTableValueType.double(2.5)
        XCTAssertTrue(a < b)
    }

    // MARK: - Sorting Simulation Tests

    func test_sorting_arrayOfInts_ascending() {
        var values = [
            DataTableValueType.int(5),
            DataTableValueType.int(2),
            DataTableValueType.int(8),
            DataTableValueType.int(1),
            DataTableValueType.int(9)
        ]
        values.sort()

        XCTAssertEqual(values[0], .int(1))
        XCTAssertEqual(values[1], .int(2))
        XCTAssertEqual(values[2], .int(5))
        XCTAssertEqual(values[3], .int(8))
        XCTAssertEqual(values[4], .int(9))
    }

    func test_sorting_arrayOfInts_descending() {
        var values = [
            DataTableValueType.int(5),
            DataTableValueType.int(2),
            DataTableValueType.int(8)
        ]
        values.sort(by: >)

        XCTAssertEqual(values[0], .int(8))
        XCTAssertEqual(values[1], .int(5))
        XCTAssertEqual(values[2], .int(2))
    }

    func test_sorting_arrayOfStrings_alphabetically() {
        var values = [
            DataTableValueType.string("Charlie"),
            DataTableValueType.string("Alpha"),
            DataTableValueType.string("Bravo")
        ]
        values.sort()

        XCTAssertEqual(values[0], .string("Alpha"))
        XCTAssertEqual(values[1], .string("Bravo"))
        XCTAssertEqual(values[2], .string("Charlie"))
    }

    func test_sorting_withDuplicates_preservesAllValues() {
        var values = [
            DataTableValueType.int(1),
            DataTableValueType.int(2),
            DataTableValueType.int(1),
            DataTableValueType.int(2)
        ]
        values.sort()

        XCTAssertEqual(values.count, 4)
        XCTAssertEqual(values[0], .int(1))
        XCTAssertEqual(values[1], .int(1))
        XCTAssertEqual(values[2], .int(2))
        XCTAssertEqual(values[3], .int(2))
    }

    func test_sorting_emptyArray() {
        var values: [DataTableValueType] = []
        values.sort()
        XCTAssertTrue(values.isEmpty)
    }

    func test_sorting_singleElement() {
        var values = [DataTableValueType.int(42)]
        values.sort()
        XCTAssertEqual(values.count, 1)
        XCTAssertEqual(values[0], .int(42))
    }
}
