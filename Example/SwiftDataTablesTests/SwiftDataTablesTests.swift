//
//  SwiftDataTablesTests.swift
//  SwiftDataTablesTests
//
//  Created by Pavan Kataria on 18/06/2019.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

@MainActor
class SwiftDataTablesTests: XCTestCase {

    func test_swiftDataTable_withConfigurationOptions_initialises() {
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

        let dataTable = SwiftDataTable(data: [[String]](), headerTitles: [], options: configuration, frame: .zero)

        // Verify configuration was passed by checking specific properties
        XCTAssertEqual(dataTable.options.highlightedAlternatingRowColors.count, 7)
        XCTAssertEqual(dataTable.options.unhighlightedAlternatingRowColors.count, 7)
    }
}
