//
//  SwiftDataTablesTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 18/06/2019.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for core SwiftDataTable initialization and configuration.
///
/// This test class validates the fundamental behavior of `SwiftDataTable`,
/// ensuring that initialization with various configurations works correctly.
///
/// ## Test Coverage
///
/// - Table initialization with custom configurations
/// - Configuration property application
/// - Row color customization
@MainActor
class SwiftDataTablesTests: XCTestCase {

    // MARK: - Initialization Tests

    /// Verifies that a SwiftDataTable correctly initializes with custom configuration options.
    ///
    /// ## Given
    /// - A `DataTableConfiguration` with custom highlighted and unhighlighted alternating row colors
    /// - Seven custom colors defined for each color array (rainbow pattern)
    ///
    /// ## When
    /// - A `SwiftDataTable` is initialized with empty data but the custom configuration
    ///
    /// ## Then
    /// - The table's `options` should contain the custom highlighted colors
    /// - The table's `options` should contain the custom unhighlighted colors
    /// - Both color arrays should have exactly 7 colors
    func test_swiftDataTable_withConfigurationOptions_initialises() {
        // Given
        var configuration = DataTableConfiguration()
        configuration.highlightedAlternatingRowColors = [
            UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 1),
            UIColor(red: 1, green: 0.7, blue: 0.5, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0.5, alpha: 1),
            UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1),
            UIColor(red: 0.5, green: 0.7, blue: 1, alpha: 1),
            UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        ]
        configuration.unhighlightedAlternatingRowColors = [
            UIColor(red: 1, green: 0.90, blue: 0.90, alpha: 1),
            UIColor(red: 1, green: 0.90, blue: 0.7, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0.7, alpha: 1),
            UIColor(red: 0.7, green: 1, blue: 0.7, alpha: 1),
            UIColor(red: 0.7, green: 0.9, blue: 1, alpha: 1),
            UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 1)
        ]

        // When
        let dataTable = SwiftDataTable(data: [[String]](), headerTitles: [], options: configuration, frame: .zero)

        // Then
        XCTAssertEqual(dataTable.options.highlightedAlternatingRowColors.count, 7,
                       "Highlighted colors should contain all 7 custom colors")
        XCTAssertEqual(dataTable.options.unhighlightedAlternatingRowColors.count, 7,
                       "Unhighlighted colors should contain all 7 custom colors")
    }
}
