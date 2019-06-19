//
//  DataTableFixedColumnTypeTests.swift
//  SwiftDataTablesTests
//
//  Created by Pavan Kataria on 18/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

@testable import SwiftDataTables_Example

class DataTableFixedColumnTypeTests: XCTestCase {

    // Test variations
    func test_fixedColumn_leftColumnInitialisation() {
        var fixedColumns = DataTableFixedColumnType(leftColumns: 2)
        XCTAssertEqual(fixedColumns.leftColumns, 2)
        XCTAssertEqual(fixedColumns.rightColumns, 0)
        
        fixedColumns = DataTableFixedColumnType(leftColumns: 4)
        XCTAssertEqual(fixedColumns.leftColumns, 4)
        XCTAssertEqual(fixedColumns.rightColumns, 0)
    }
    
    func test_fixedColumn_rightColumnInitialisation() {
        var fixedColumns = DataTableFixedColumnType(rightColumns: 2)
        XCTAssertEqual(fixedColumns.leftColumns, 0)
        XCTAssertEqual(fixedColumns.rightColumns, 2)
        fixedColumns = DataTableFixedColumnType(rightColumns: 1)
        XCTAssertEqual(fixedColumns.leftColumns, 0)
        XCTAssertEqual(fixedColumns.rightColumns, 1)
    }
    
    func test_fixedColumn_leftAndRightColumnInitialisation() {
        var fixedColumns = DataTableFixedColumnType(leftColumns: 3, rightColumns: 1)
        XCTAssertEqual(fixedColumns.leftColumns, 3)
        XCTAssertEqual(fixedColumns.rightColumns, 1)
        
        fixedColumns = DataTableFixedColumnType(leftColumns: 1, rightColumns: 3)
        XCTAssertEqual(fixedColumns.leftColumns, 1)
        XCTAssertEqual(fixedColumns.rightColumns, 3)
    }
}
