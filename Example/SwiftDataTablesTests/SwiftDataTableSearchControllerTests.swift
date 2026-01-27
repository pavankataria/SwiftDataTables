//
//  SwiftDataTableSearchControllerTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for search controller integration with SwiftDataTable.
///
/// These tests verify:
/// - Search controller creation with proper updater and placeholder
/// - Search controller installation on view controller navigation item
/// - Embedded search bar visibility control
@MainActor
final class SwiftDataTableSearchControllerTests: XCTestCase {
    func test_makeSearchController_setsUpdaterAndPlaceholder() {
        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"])
        let controller = table.makeSearchController()

        XCTAssertTrue(controller.searchResultsUpdater === table)
        XCTAssertEqual(controller.searchBar.placeholder, "Search")
        XCTAssertFalse(controller.obscuresBackgroundDuringPresentation)
    }

    func test_installSearchController_hidesEmbeddedSearchAndInstallsController() {
        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"])
        let viewController = UIViewController()

        _ = table.installSearchController(on: viewController)

        XCTAssertNotNil(viewController.navigationItem.searchController)
        XCTAssertTrue(table.searchBar.isHidden)
    }

    func test_shouldShowSearchSection_false_hidesEmbeddedSearchBar() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(
            data: [["A"]],
            headerTitles: ["H"],
            options: config,
            frame: CGRect(x: 0, y: 0, width: 320, height: 480)
        )
        table.setNeedsLayout()
        table.layoutIfNeeded()

        XCTAssertTrue(table.searchBar.isHidden)
    }
}
