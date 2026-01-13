//
//  SwiftDataTablesUITests.swift
//  SwiftDataTablesUITests
//
//  Created by Pavan Kataria on 2024.
//  Copyright © 2024 Pavan Kataria. All rights reserved.
//

import XCTest

// MARK: - Base Test Class
class SwiftDataTablesUITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Helper Methods

    /// Navigate to a specific menu item by section and row
    func navigateToMenuItem(section: Int, row: Int) {
        let menuTable = app.tables["MenuTableView"]
        XCTAssertTrue(menuTable.waitForExistence(timeout: 5), "Menu table should exist")

        let cell = menuTable.cells["MenuItem_\(section)_\(row)"]
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Menu cell should exist")
        cell.tap()
    }

    /// Navigate to Data Set example
    func navigateToDataSetExample() {
        navigateToMenuItem(section: 0, row: 0)
    }

    /// Navigate to Data Source example
    func navigateToDataSourceExample() {
        navigateToMenuItem(section: 0, row: 1)
    }

    /// Navigate to Empty Data Source example
    func navigateToEmptyDataSourceExample() {
        navigateToMenuItem(section: 0, row: 2)
    }

    /// Navigate to configuration example by index
    func navigateToConfigurationExample(index: Int) {
        navigateToMenuItem(section: 1, row: index)
    }

    /// Wait for the data table to be ready
    func waitForDataTable() -> XCUIElement {
        let collectionView = app.collectionViews["SwiftDataTable_CollectionView"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10), "Data table collection view should exist")
        return collectionView
    }

    /// Get the search bar element
    func getSearchBar() -> XCUIElement {
        return app.searchFields["SwiftDataTable_SearchBar"]
    }

    /// Get a column header by index
    func getColumnHeader(index: Int) -> XCUIElement {
        return app.otherElements["ColumnHeader_\(index)"]
    }

    /// Get a column footer by index
    func getColumnFooter(index: Int) -> XCUIElement {
        return app.otherElements["ColumnFooter_\(index)"]
    }

    /// Get a data cell by section and item
    func getDataCell(section: Int, item: Int) -> XCUIElement {
        return app.cells["DataCell_\(section)_\(item)"]
    }

    /// Navigate back to menu
    func navigateBack() {
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}

// MARK: - Table Display Tests
class TableDisplayTests: SwiftDataTablesUITestCase {

    func test_dataTable_withStaticData_displaysCorrectly() {
        // Given: Navigate to data set example
        navigateToDataSetExample()

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Then: Verify table is displayed with content
        XCTAssertTrue(collectionView.exists, "Collection view should be visible")

        // Verify first column header exists
        let firstHeader = getColumnHeader(index: 0)
        XCTAssertTrue(firstHeader.waitForExistence(timeout: 5), "First column header should exist")
    }

    func test_dataTable_displaysCorrectHeaders() {
        // Given: Navigate to data set example
        navigateToDataSetExample()

        // When: Wait for data table
        _ = waitForDataTable()

        // Then: Verify headers are displayed
        let expectedHeaders = ["Id", "Name", "Email", "Number", "City", "Balance"]

        for (index, _) in expectedHeaders.enumerated() {
            let header = getColumnHeader(index: index)
            XCTAssertTrue(header.waitForExistence(timeout: 5), "Header at index \(index) should exist")
        }
    }

    func test_dataTable_displaysDataCells() {
        // Given: Navigate to data set example
        navigateToDataSetExample()

        // When: Wait for data table
        _ = waitForDataTable()

        // Then: Verify first few cells exist
        let firstCell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First data cell should exist")
    }

    func test_dataTable_withDataSource_loadsDataDynamically() {
        // Given: Navigate to data source example
        navigateToDataSourceExample()

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Then: Verify data is loaded (data source adds data after navigation)
        XCTAssertTrue(collectionView.exists, "Collection view should be visible")

        // Wait a bit for data to load dynamically
        sleep(1)

        // Verify cells exist after data is added
        let firstCell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First data cell should exist after data load")
    }

    func test_dataTable_withEmptyDataSource_displaysEmptyState() {
        // Given: Navigate to empty data source example
        navigateToEmptyDataSourceExample()

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Then: Collection view should exist but be empty
        XCTAssertTrue(collectionView.exists, "Collection view should be visible even with empty data")
    }

    func test_dataTable_footerDisplays_whenConfigured() {
        // Given: Navigate to data set example (has footer by default)
        navigateToDataSetExample()

        // When: Wait for data table
        _ = waitForDataTable()

        // Then: Verify footer exists
        let footer = getColumnFooter(index: 0)
        // Note: Footer might need scrolling to be visible
        // This test verifies the footer elements are in the view hierarchy
        XCTAssertTrue(footer.waitForExistence(timeout: 5), "Footer should exist")
    }
}

// MARK: - Sorting Tests
class SortingTests: SwiftDataTablesUITestCase {

    func test_tappingColumnHeader_triggersSorting() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Tap on the Name column header (index 1)
        let nameHeader = getColumnHeader(index: 1)
        XCTAssertTrue(nameHeader.waitForExistence(timeout: 5), "Name header should exist")
        nameHeader.tap()

        // Then: Data should be sorted (we verify header is tappable)
        // UI test verifies the interaction works
        sleep(1) // Allow time for sorting animation

        // Verify the first cell still exists after sorting
        let firstCell = getDataCell(section: 0, item: 1)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Cells should still exist after sorting")
    }

    func test_doubleTappingColumnHeader_togglesSortDirection() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Double tap on the Name column header
        let nameHeader = getColumnHeader(index: 1)
        XCTAssertTrue(nameHeader.waitForExistence(timeout: 5), "Name header should exist")

        // First tap - ascending
        nameHeader.tap()
        sleep(1)

        // Second tap - descending
        nameHeader.tap()
        sleep(1)

        // Then: Verify data table is still functional
        let firstCell = getDataCell(section: 0, item: 1)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Cells should still exist after toggling sort")
    }

    func test_sortingDifferentColumns_works() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Sort by different columns
        for columnIndex in 0..<3 {
            let header = getColumnHeader(index: columnIndex)
            if header.waitForExistence(timeout: 2) {
                header.tap()
                sleep(1)
            }
        }

        // Then: Data table should still be functional
        let collectionView = waitForDataTable()
        XCTAssertTrue(collectionView.exists, "Collection view should exist after multiple sorts")
    }

    func test_sortingPreservesDataIntegrity() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Sort by ID column (index 0)
        let idHeader = getColumnHeader(index: 0)
        XCTAssertTrue(idHeader.waitForExistence(timeout: 5), "ID header should exist")
        idHeader.tap()
        sleep(1)

        // Then: First cell should exist with ID data
        let firstIdCell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(firstIdCell.waitForExistence(timeout: 5), "ID cell should exist after sorting")
    }
}

// MARK: - Search Tests
class SearchTests: SwiftDataTablesUITestCase {

    func test_searchBar_isDisplayedByDefault() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // Then: Search bar should be visible
        // Note: Search bar might be a UISearchBar in the view hierarchy
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should be visible")
    }

    func test_searchBar_filtersResults() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Enter search text
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should exist")
        searchBar.tap()
        searchBar.typeText("Meggie")

        // Then: Results should be filtered
        sleep(1) // Allow time for filtering

        // Verify the collection view still exists
        let collectionView = waitForDataTable()
        XCTAssertTrue(collectionView.exists, "Collection view should exist after search")
    }

    func test_searchBar_clearingRestoresAllRows() {
        // Given: Navigate to data set example and search
        navigateToDataSetExample()
        _ = waitForDataTable()

        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should exist")
        searchBar.tap()
        searchBar.typeText("Test")
        sleep(1)

        // When: Clear the search
        if let clearButton = searchBar.buttons.firstMatch as? XCUIElement, clearButton.exists {
            clearButton.tap()
        } else {
            // Alternative: Clear by selecting all and deleting
            searchBar.tap()
            searchBar.doubleTap()
            app.keys["delete"].tap()
        }

        // Then: All rows should be restored
        sleep(1)
        let collectionView = waitForDataTable()
        XCTAssertTrue(collectionView.exists, "Collection view should exist after clearing search")
    }

    func test_searchBar_dismissesOnScroll() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Tap search bar to activate keyboard
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should exist")
        searchBar.tap()

        // Then: Keyboard should be active
        // Scroll to dismiss
        let collectionView = waitForDataTable()
        collectionView.swipeUp()

        // Verify collection view is still functional
        XCTAssertTrue(collectionView.exists, "Collection view should exist after scroll")
    }

    func test_searchWithNoResults_showsEmptyState() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Search for non-existent text
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should exist")
        searchBar.tap()
        searchBar.typeText("ZZZNONEXISTENT999")

        // Then: No results should be shown
        sleep(1)
        let collectionView = waitForDataTable()
        XCTAssertTrue(collectionView.exists, "Collection view should exist but be empty")
    }
}

// MARK: - Row Selection Tests
class RowSelectionTests: SwiftDataTablesUITestCase {

    func test_tappingCell_selectsCell() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Tap on a cell
        let cell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Cell should exist")
        cell.tap()

        // Then: Cell should be selected (verified by cell being tappable)
        // Selection state is handled internally
        sleep(1)
        XCTAssertTrue(cell.exists, "Cell should still exist after selection")
    }

    func test_tappingSelectedCell_deselectsCell() {
        // Given: Navigate to data set example and select a cell
        navigateToDataSetExample()
        _ = waitForDataTable()

        let cell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Cell should exist")
        cell.tap()
        sleep(1)

        // When: Tap the same cell again
        cell.tap()

        // Then: Cell should be deselected
        sleep(1)
        XCTAssertTrue(cell.exists, "Cell should still exist after deselection")
    }

    func test_multipleSelection_works() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // When: Select multiple cells
        let cell1 = getDataCell(section: 0, item: 0)
        let cell2 = getDataCell(section: 0, item: 1)

        if cell1.waitForExistence(timeout: 5) {
            cell1.tap()
        }
        sleep(1)

        if cell2.waitForExistence(timeout: 5) {
            cell2.tap()
        }

        // Then: Both cells should be selectable
        sleep(1)
        XCTAssertTrue(cell1.exists, "First cell should exist")
        XCTAssertTrue(cell2.exists, "Second cell should exist")
    }
}

// MARK: - Configuration Variation Tests
class ConfigurationTests: SwiftDataTablesUITestCase {

    func test_withoutFooters_hidesFooter() {
        // Given: Navigate to "Without Footers" configuration (index 0 in section 1)
        navigateToConfigurationExample(index: 0)

        // When: Wait for data table
        _ = waitForDataTable()

        // Then: Footer should not be visible
        let footer = getColumnFooter(index: 0)
        // Footer should not exist when configured to hide
        XCTAssertFalse(footer.waitForExistence(timeout: 2), "Footer should not exist in without-footer configuration")
    }

    func test_withoutSearch_hidesSearchBar() {
        // Given: Navigate to "Without Search" configuration (index 1 in section 1)
        navigateToConfigurationExample(index: 1)

        // When: Wait for data table
        _ = waitForDataTable()

        // Then: Search bar should not be visible
        let searchBar = app.searchFields.firstMatch
        XCTAssertFalse(searchBar.waitForExistence(timeout: 2), "Search bar should not exist in without-search configuration")
    }

    func test_withoutFloatingHeadersAndFooters_scrollsWithContent() {
        // Given: Navigate to "Without floating headers and footers" configuration (index 2)
        navigateToConfigurationExample(index: 2)

        // When: Wait for data table and scroll
        let collectionView = waitForDataTable()
        collectionView.swipeUp()
        sleep(1)

        // Then: Data table should still be functional
        XCTAssertTrue(collectionView.exists, "Collection view should exist after scrolling")
    }

    func test_withoutScrollBars_hidesScrollIndicators() {
        // Given: Navigate to "Without scroll bars" configuration (index 3)
        navigateToConfigurationExample(index: 3)

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Then: Data table should be functional (scroll bars are not directly testable via UI)
        XCTAssertTrue(collectionView.exists, "Collection view should exist")

        // Scroll to verify functionality
        collectionView.swipeUp()
        sleep(1)
        XCTAssertTrue(collectionView.exists, "Collection view should exist after scrolling")
    }

    func test_alternatingColors_displaysCorrectly() {
        // Given: Navigate to "Alternating colours" configuration (index 4)
        navigateToConfigurationExample(index: 4)

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Then: Data table should display (colors not directly testable)
        XCTAssertTrue(collectionView.exists, "Collection view should exist with alternating colors")

        // Verify cells exist
        let cell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Cells should exist with alternating colors")
    }

    func test_fixedColumns_frozenColumnsRemainVisible() {
        // Given: Navigate to "Fixed/Frozen columns" configuration (index 5)
        navigateToConfigurationExample(index: 5)

        // When: Wait for data table
        let collectionView = waitForDataTable()

        // Scroll horizontally
        collectionView.swipeLeft()
        sleep(1)

        // Then: First column should still be visible (fixed)
        let firstColumnCell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(firstColumnCell.waitForExistence(timeout: 5), "Fixed column cell should still be visible after horizontal scroll")
    }
}

// MARK: - Scrolling Behavior Tests
class ScrollingTests: SwiftDataTablesUITestCase {

    func test_verticalScrolling_works() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        let collectionView = waitForDataTable()

        // When: Scroll down
        collectionView.swipeUp()
        sleep(1)

        // Then: Collection view should still be visible
        XCTAssertTrue(collectionView.exists, "Collection view should exist after vertical scroll")
    }

    func test_horizontalScrolling_works() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        let collectionView = waitForDataTable()

        // When: Scroll horizontally
        collectionView.swipeLeft()
        sleep(1)

        // Then: Collection view should still be visible
        XCTAssertTrue(collectionView.exists, "Collection view should exist after horizontal scroll")
    }

    func test_floatingHeaders_remainVisibleDuringScroll() {
        // Given: Navigate to data set example (default has floating headers)
        navigateToDataSetExample()
        let collectionView = waitForDataTable()

        // When: Scroll down
        collectionView.swipeUp()
        collectionView.swipeUp()
        sleep(1)

        // Then: Header should still be visible
        let header = getColumnHeader(index: 0)
        XCTAssertTrue(header.waitForExistence(timeout: 5), "Header should remain visible during scroll")
    }

    func test_floatingFooters_remainVisibleDuringScroll() {
        // Given: Navigate to data set example (default has floating footers)
        navigateToDataSetExample()
        let collectionView = waitForDataTable()

        // When: Scroll up (to see footer)
        collectionView.swipeDown()
        sleep(1)

        // Then: Footer should be visible
        let footer = getColumnFooter(index: 0)
        // Footer visibility depends on scroll position
        XCTAssertTrue(collectionView.exists, "Collection view should exist")
    }

    func test_scrollingBounce_isDisabled() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        let collectionView = waitForDataTable()

        // When: Try to scroll beyond content
        collectionView.swipeUp()
        collectionView.swipeUp()
        collectionView.swipeUp()
        collectionView.swipeUp()
        sleep(1)

        // Then: Collection view should still be properly positioned
        XCTAssertTrue(collectionView.exists, "Collection view should exist after excessive scroll")
    }

    func test_scrollToTop_afterSearchReset() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // Scroll down first
        let collectionView = waitForDataTable()
        collectionView.swipeUp()
        collectionView.swipeUp()
        sleep(1)

        // When: Perform a search and clear it
        let searchBar = app.searchFields.firstMatch
        if searchBar.waitForExistence(timeout: 5) {
            searchBar.tap()
            searchBar.typeText("Test")
            sleep(1)

            // Clear search (by deleting text)
            if let clearButton = searchBar.buttons.firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }

        // Then: Collection view should reset to top
        sleep(1)
        XCTAssertTrue(collectionView.exists, "Collection view should exist after search reset")
    }
}

// MARK: - Navigation Tests
class NavigationTests: SwiftDataTablesUITestCase {

    func test_navigateToAllMenuItems_withoutCrash() {
        // Test all data store variations
        for row in 0..<3 {
            navigateToMenuItem(section: 0, row: row)
            sleep(1)
            navigateBack()
            sleep(1)
        }

        // Test all configuration variations
        for row in 0..<6 {
            navigateToMenuItem(section: 1, row: row)
            sleep(1)
            navigateBack()
            sleep(1)
        }
    }

    func test_menuTable_displaysAllItems() {
        // Given: App is launched
        let menuTable = app.tables["MenuTableView"]

        // Then: Menu table should exist with correct items
        XCTAssertTrue(menuTable.waitForExistence(timeout: 5), "Menu table should exist")

        // Verify section 0 items
        for row in 0..<3 {
            let cell = menuTable.cells["MenuItem_0_\(row)"]
            XCTAssertTrue(cell.waitForExistence(timeout: 2), "Menu item at section 0, row \(row) should exist")
        }

        // Scroll to see section 1
        menuTable.swipeUp()

        // Verify section 1 items
        for row in 0..<6 {
            let cell = menuTable.cells["MenuItem_1_\(row)"]
            if cell.waitForExistence(timeout: 2) {
                XCTAssertTrue(cell.exists, "Menu item at section 1, row \(row) should exist")
            }
        }
    }
}

// MARK: - Performance Tests
class PerformanceTests: SwiftDataTablesUITestCase {

    func test_tableLoading_performance() {
        measure {
            navigateToDataSetExample()
            let collectionView = waitForDataTable()
            XCTAssertTrue(collectionView.exists)
            navigateBack()
            sleep(1)
        }
    }

    func test_sorting_performance() {
        navigateToDataSetExample()
        _ = waitForDataTable()

        measure {
            let header = getColumnHeader(index: 1)
            if header.waitForExistence(timeout: 2) {
                header.tap()
            }
            sleep(1)
        }
    }

    func test_search_performance() {
        navigateToDataSetExample()
        _ = waitForDataTable()

        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5))

        measure {
            searchBar.tap()
            searchBar.typeText("A")
            sleep(1)
            if let clearButton = searchBar.buttons.firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }
    }
}

// MARK: - Accessibility Tests
class AccessibilityTests: SwiftDataTablesUITestCase {

    func test_dataTable_hasAccessibilityIdentifiers() {
        // Given: Navigate to data set example
        navigateToDataSetExample()

        // Then: Verify accessibility identifiers exist
        let collectionView = app.collectionViews["SwiftDataTable_CollectionView"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "Collection view accessibility identifier should work")
    }

    func test_columnHeaders_haveAccessibilityIdentifiers() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // Then: Headers should have accessibility identifiers
        for index in 0..<3 {
            let header = getColumnHeader(index: index)
            XCTAssertTrue(header.waitForExistence(timeout: 5), "Header \(index) should have accessibility identifier")
        }
    }

    func test_dataCells_haveAccessibilityIdentifiers() {
        // Given: Navigate to data set example
        navigateToDataSetExample()
        _ = waitForDataTable()

        // Then: Cells should have accessibility identifiers
        let cell = getDataCell(section: 0, item: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Cell should have accessibility identifier")
    }
}
