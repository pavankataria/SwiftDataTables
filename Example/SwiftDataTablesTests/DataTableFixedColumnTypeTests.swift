//
//  DataTableFixedColumnTypeTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
@testable import SwiftDataTables

/// Tests for `DataTableFixedColumnType` that configures frozen columns.
///
/// These tests verify:
/// - Initialization with left and/or right fixed columns
/// - Hit test detection for left fixed columns
/// - Hit test detection for right fixed columns
/// - Hit test detection with both left and right columns
/// - Edge cases (no fixed columns, all fixed, overlapping)
class DataTableFixedColumnTypeTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withLeftAndRightColumns() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 2, rightColumns: 3)
        XCTAssertEqual(fixedColumns.leftColumns, 2)
        XCTAssertEqual(fixedColumns.rightColumns, 3)
    }

    func test_init_withOnlyLeftColumns() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 2)
        XCTAssertEqual(fixedColumns.leftColumns, 2)
        XCTAssertEqual(fixedColumns.rightColumns, 0)
    }

    func test_init_withOnlyRightColumns() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 2)
        XCTAssertEqual(fixedColumns.leftColumns, 0)
        XCTAssertEqual(fixedColumns.rightColumns, 2)
    }

    func test_init_withZeroColumns() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 0, rightColumns: 0)
        XCTAssertEqual(fixedColumns.leftColumns, 0)
        XCTAssertEqual(fixedColumns.rightColumns, 0)
    }

    // MARK: - Hit Test Left Column Tests

    func test_hitTest_firstColumnIsLeft_whenLeftColumnsIs1() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 1)
        let result = fixedColumns.hitTest(0, totalTableColumnCount: 5)
        XCTAssertEqual(result, .left)
    }

    func test_hitTest_secondColumnIsNotLeft_whenLeftColumnsIs1() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 1)
        let result = fixedColumns.hitTest(1, totalTableColumnCount: 5)
        XCTAssertNil(result)
    }

    func test_hitTest_multipleLeftColumnsDetectedCorrectly() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 3)

        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 10), .left)
        XCTAssertEqual(fixedColumns.hitTest(1, totalTableColumnCount: 10), .left)
        XCTAssertEqual(fixedColumns.hitTest(2, totalTableColumnCount: 10), .left)
        XCTAssertNil(fixedColumns.hitTest(3, totalTableColumnCount: 10))
    }

    func test_hitTest_boundaryColumnIndexForLeftColumns() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 2)

        XCTAssertEqual(fixedColumns.hitTest(1, totalTableColumnCount: 5), .left) // Last left column
        XCTAssertNil(fixedColumns.hitTest(2, totalTableColumnCount: 5))          // First non-fixed
    }

    // MARK: - Hit Test Right Column Tests

    func test_hitTest_lastColumnIsRight_whenRightColumnsIs1() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 1)
        let result = fixedColumns.hitTest(4, totalTableColumnCount: 5) // Index 4 = last of 5
        XCTAssertEqual(result, .right)
    }

    func test_hitTest_secondToLastIsNotRight_whenRightColumnsIs1() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 1)
        let result = fixedColumns.hitTest(3, totalTableColumnCount: 5) // Index 3 = second to last
        XCTAssertNil(result)
    }

    func test_hitTest_multipleRightColumnsDetectedCorrectly() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 3)

        // 10 columns total, rightColumns = 3 means columns 7, 8, 9 are fixed
        XCTAssertNil(fixedColumns.hitTest(6, totalTableColumnCount: 10))
        XCTAssertEqual(fixedColumns.hitTest(7, totalTableColumnCount: 10), .right)
        XCTAssertEqual(fixedColumns.hitTest(8, totalTableColumnCount: 10), .right)
        XCTAssertEqual(fixedColumns.hitTest(9, totalTableColumnCount: 10), .right)
    }

    func test_hitTest_boundaryColumnIndexForRightColumns() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 2)

        // 5 columns total, rightColumns = 2 means columns 3, 4 are fixed
        XCTAssertNil(fixedColumns.hitTest(2, totalTableColumnCount: 5))          // Last non-fixed
        XCTAssertEqual(fixedColumns.hitTest(3, totalTableColumnCount: 5), .right) // First right column
    }

    // MARK: - Hit Test Both Sides Tests

    func test_hitTest_leftAndRightColumnsDetectedCorrectly() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 2, rightColumns: 2)

        // 10 columns: 0,1 = left | 2-7 = middle | 8,9 = right
        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 10), .left)
        XCTAssertEqual(fixedColumns.hitTest(1, totalTableColumnCount: 10), .left)
        XCTAssertNil(fixedColumns.hitTest(2, totalTableColumnCount: 10))
        XCTAssertNil(fixedColumns.hitTest(5, totalTableColumnCount: 10))
        XCTAssertNil(fixedColumns.hitTest(7, totalTableColumnCount: 10))
        XCTAssertEqual(fixedColumns.hitTest(8, totalTableColumnCount: 10), .right)
        XCTAssertEqual(fixedColumns.hitTest(9, totalTableColumnCount: 10), .right)
    }

    func test_hitTest_middleColumnsReturnNil() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 1, rightColumns: 1)

        // 5 columns: 0 = left | 1,2,3 = middle | 4 = right
        XCTAssertNil(fixedColumns.hitTest(1, totalTableColumnCount: 5))
        XCTAssertNil(fixedColumns.hitTest(2, totalTableColumnCount: 5))
        XCTAssertNil(fixedColumns.hitTest(3, totalTableColumnCount: 5))
    }

    // MARK: - Edge Cases

    func test_hitTest_noFixedColumnsReturnsNilForAll() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 0, rightColumns: 0)

        XCTAssertNil(fixedColumns.hitTest(0, totalTableColumnCount: 5))
        XCTAssertNil(fixedColumns.hitTest(2, totalTableColumnCount: 5))
        XCTAssertNil(fixedColumns.hitTest(4, totalTableColumnCount: 5))
    }

    func test_hitTest_allColumnsFixedAsLeft() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 5)

        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 5), .left)
        XCTAssertEqual(fixedColumns.hitTest(2, totalTableColumnCount: 5), .left)
        XCTAssertEqual(fixedColumns.hitTest(4, totalTableColumnCount: 5), .left)
    }

    func test_hitTest_allColumnsFixedAsRight() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 5)

        // All 5 columns should be right
        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 5), .right)
        XCTAssertEqual(fixedColumns.hitTest(2, totalTableColumnCount: 5), .right)
        XCTAssertEqual(fixedColumns.hitTest(4, totalTableColumnCount: 5), .right)
    }

    func test_hitTest_singleColumnTableWithOneLeftFixed() {
        let fixedColumns = DataTableFixedColumnType(leftColumns: 1)
        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 1), .left)
    }

    func test_hitTest_singleColumnTableWithOneRightFixed() {
        let fixedColumns = DataTableFixedColumnType(rightColumns: 1)
        XCTAssertEqual(fixedColumns.hitTest(0, totalTableColumnCount: 1), .right)
    }

    func test_hitTest_overlappingFixedColumnsPrioritizesLeft() {
        // If leftColumns + rightColumns >= totalColumns, left takes precedence
        let fixedColumns = DataTableFixedColumnType(leftColumns: 3, rightColumns: 3)

        // 5 columns: left claims 0,1,2; right claims 2,3,4
        // Column 2 should be left (checked first)
        XCTAssertEqual(fixedColumns.hitTest(2, totalTableColumnCount: 5), .left)
    }

    // MARK: - DataTableFixedColumnSideType Tests

    func test_sideType_leftExists() {
        let sideType = DataTableFixedColumnSideType.left
        XCTAssertEqual(sideType, .left)
    }

    func test_sideType_rightExists() {
        let sideType = DataTableFixedColumnSideType.right
        XCTAssertEqual(sideType, .right)
    }

    func test_sideType_leftAndRightAreDifferent() {
        XCTAssertNotEqual(DataTableFixedColumnSideType.left, DataTableFixedColumnSideType.right)
    }
}
