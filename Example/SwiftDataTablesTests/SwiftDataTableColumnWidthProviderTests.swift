//
//  SwiftDataTableColumnWidthProviderTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for `columnWidthModeProvider` configuration feature.
///
/// These tests verify:
/// - Per-column width mode override using provider closure
/// - Provider returning nil falls back to global columnWidthMode
/// - Proper width calculation with provider-specified modes
@MainActor
final class SwiftDataTableColumnWidthProviderTests: XCTestCase {
    func test_columnWidthModeProvider_overridesPerColumn() {
        var options = DataTableConfiguration()
        options.columnWidthMode = .fixed(width: 40)
        options.minColumnWidth = 0
        options.columnWidthModeProvider = { index in
            if index == 1 { return .fixed(width: 120) }
            return nil
        }

        let table = SwiftDataTable(
            data: [["A", "B"]],
            headerTitles: ["H1", "H2"],
            options: options
        )
        table.calculateColumnWidths()

        let headerFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        let expectedColumn0 = expectedWidth(
            header: "H1",
            baseContentWidth: 40,
            config: options,
            headerFont: headerFont
        )
        let expectedColumn1 = expectedWidth(
            header: "H2",
            baseContentWidth: 120,
            config: options,
            headerFont: headerFont
        )

        XCTAssertEqual(table.widthForColumn(index: 0), expectedColumn0, accuracy: 0.5)
        XCTAssertEqual(table.widthForColumn(index: 1), expectedColumn1, accuracy: 0.5)
    }
}

private func expectedWidth(
    header: String,
    baseContentWidth: CGFloat,
    config: DataTableConfiguration,
    headerFont: UIFont
) -> CGFloat {
    let headerMinimum = header.widthOfString(usingFont: headerFont)
        + DataHeaderFooter.Properties.sortIndicatorWidth
        + DataHeaderFooter.Properties.labelHorizontalMargin
    let minClamped = max(baseContentWidth, config.minColumnWidth)
    let maxClamped = config.maxColumnWidth.map { min(minClamped, $0) } ?? minClamped
    return max(maxClamped, headerMinimum)
}
