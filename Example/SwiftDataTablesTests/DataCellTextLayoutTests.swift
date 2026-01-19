//
//  DataCellTextLayoutTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
final class DataCellTextLayoutTests: XCTestCase {
    func test_applyTextLayout_singleLine_truncatesHead() {
        let cell = DataCell(frame: .zero)
        cell.applyTextLayout(.singleLine(truncation: .byTruncatingHead))

        XCTAssertEqual(cell.dataLabel.numberOfLines, 1)
        XCTAssertEqual(cell.dataLabel.lineBreakMode, .byTruncatingHead)
    }

    func test_applyTextLayout_singleLine_truncatesMiddle() {
        let cell = DataCell(frame: .zero)
        cell.applyTextLayout(.singleLine(truncation: .byTruncatingMiddle))

        XCTAssertEqual(cell.dataLabel.numberOfLines, 1)
        XCTAssertEqual(cell.dataLabel.lineBreakMode, .byTruncatingMiddle)
    }

    func test_applyTextLayout_singleLine_truncatesTail() {
        let cell = DataCell(frame: .zero)
        cell.applyTextLayout(.singleLine(truncation: .byTruncatingTail))

        XCTAssertEqual(cell.dataLabel.numberOfLines, 1)
        XCTAssertEqual(cell.dataLabel.lineBreakMode, .byTruncatingTail)
    }

    func test_applyTextLayout_wrap_allowsMultipleLines() {
        let cell = DataCell(frame: .zero)
        cell.applyTextLayout(.wrap)

        XCTAssertEqual(cell.dataLabel.numberOfLines, 0)
        XCTAssertEqual(cell.dataLabel.lineBreakMode, .byWordWrapping)
    }
}
