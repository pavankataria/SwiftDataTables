//
//  SwiftDataTableRowHeightTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
final class SwiftDataTableRowHeightTests: XCTestCase {
    func test_heightForRow_fixedMode_returnsFixedHeight() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .fixed(80)

        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"], options: options)
        let height = table.heightForRow(index: 0)

        XCTAssertEqual(height, 80)
    }

    func test_heightForRow_automatic_unmeasured_returnsEstimatedHeight() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)
        options.textLayout = .singleLine()
        options.minColumnWidth = 0

        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"], options: options)
        table.calculateColumnWidths()

        // Automatic mode uses lazy measurement - unmeasured rows return estimated height
        XCTAssertEqual(table.heightForRow(index: 0), 44, accuracy: 0.5)
    }

    func test_heightForRow_automatic_measured_matchesActualHeight() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)
        options.textLayout = .singleLine()
        options.minColumnWidth = 0

        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"], options: options)

        // Embed in window to trigger measurement
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        // Row should now be measured
        let font = DataCell.Properties.defaultFont
        let verticalPadding = DataCell.Properties.verticalMargin * 2
        let expected = ceil(font.lineHeight + verticalPadding)

        XCTAssertEqual(table.heightForRow(index: 0), expected, accuracy: 0.5)
    }

    func test_heightForRow_automatic_wrap_exceedsSingleLineHeight() {
        var options = DataTableConfiguration()
        options.rowHeightMode = .automatic(estimated: 44)
        options.textLayout = .wrap
        options.columnWidthMode = .fixed(width: 60)
        options.minColumnWidth = 0
        options.maxColumnWidth = 60

        let longText = String(repeating: "Wrap ", count: 40)
        let table = SwiftDataTable(data: [[longText]], headerTitles: [""], options: options)

        // Embed in window to trigger measurement
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(table)
        table.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
        window.makeKeyAndVisible()
        table.layoutIfNeeded()

        let font = DataCell.Properties.defaultFont
        let verticalPadding = DataCell.Properties.verticalMargin * 2
        let singleLineHeight = ceil(font.lineHeight + verticalPadding)

        XCTAssertGreaterThan(table.heightForRow(index: 0), singleLineHeight)
    }
}
