//
//  DataTableConfigurationTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
import UIKit
@testable import SwiftDataTables

class DataTableConfigurationTests: XCTestCase {

    // MARK: - Default Values Tests

    func test_default_footerHeight_is44() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.heightForSectionFooter, 44)
    }

    func test_default_headerHeight_is44() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.heightForSectionHeader, 44)
    }

    func test_default_searchViewHeight_is60() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.heightForSearchView, 60)
    }

    func test_default_interRowSpacing_is1() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.heightOfInterRowSpacing, 1)
    }

    func test_default_shouldShowFooter_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldShowFooter)
    }

    func test_default_shouldShowSearchSection_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldShowSearchSection)
    }

    func test_default_shouldSearchHeaderFloat_isFalse() {
        let config = DataTableConfiguration()
        XCTAssertFalse(config.shouldSearchHeaderFloat)
    }

    func test_default_shouldSectionFootersFloat_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldSectionFootersFloat)
    }

    func test_default_shouldSectionHeadersFloat_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldSectionHeadersFloat)
    }

    func test_default_shouldContentWidthScaleToFillFrame_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldContentWidthScaleToFillFrame)
    }

    func test_default_shouldShowVerticalScrollBars_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldShowVerticalScrollBars)
    }

    func test_default_shouldShowHorizontalScrollBars_isFalse() {
        let config = DataTableConfiguration()
        XCTAssertFalse(config.shouldShowHorizontalScrollBars)
    }

    func test_default_sortArrowTintColor_isBlue() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.sortArrowTintColor, UIColor.blue)
    }

    func test_default_shouldSupportRightToLeftInterfaceDirection_isTrue() {
        let config = DataTableConfiguration()
        XCTAssertTrue(config.shouldSupportRightToLeftInterfaceDirection)
    }

    func test_default_defaultOrdering_isNil() {
        let config = DataTableConfiguration()
        XCTAssertNil(config.defaultOrdering)
    }

    func test_default_fixedColumns_isNil() {
        let config = DataTableConfiguration()
        XCTAssertNil(config.fixedColumns)
    }

    func test_default_columnWidthMode_isEstimatedText() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.columnWidthMode, DataTableConfiguration.defaultColumnWidthMode)
    }

    func test_default_textLayout_isSingleLine() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.textLayout, .singleLine())
    }

    func test_default_rowHeightMode_isFixed44() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.rowHeightMode, .fixed(44))
    }

    func test_default_cellSizingMode_isDefaultCell() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.cellSizingMode, .defaultCell)
    }

    func test_default_columnWidthModeProvider_isNil() {
        let config = DataTableConfiguration()
        XCTAssertNil(config.columnWidthModeProvider)
    }

    func test_default_minAndMaxColumnWidth_defaults() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.minColumnWidth, 70)
        XCTAssertNil(config.maxColumnWidth)
    }

    func test_default_highlightedAlternatingRowColors_hasTwoColors() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.highlightedAlternatingRowColors.count, 2)
    }

    func test_default_unhighlightedAlternatingRowColors_hasTwoColors() {
        let config = DataTableConfiguration()
        XCTAssertEqual(config.unhighlightedAlternatingRowColors.count, 2)
    }

    // MARK: - Custom Configuration Tests

    func test_canCustomize_footerHeight() {
        var config = DataTableConfiguration()
        config.heightForSectionFooter = 60
        XCTAssertEqual(config.heightForSectionFooter, 60)
    }

    func test_canHide_footer() {
        var config = DataTableConfiguration()
        config.shouldShowFooter = false
        XCTAssertFalse(config.shouldShowFooter)
    }

    func test_canHide_searchSection() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        XCTAssertFalse(config.shouldShowSearchSection)
    }

    func test_canDisable_floatingHeaders() {
        var config = DataTableConfiguration()
        config.shouldSectionHeadersFloat = false
        XCTAssertFalse(config.shouldSectionHeadersFloat)
    }

    func test_canDisable_floatingFooters() {
        var config = DataTableConfiguration()
        config.shouldSectionFootersFloat = false
        XCTAssertFalse(config.shouldSectionFootersFloat)
    }

    func test_canShow_horizontalScrollBars() {
        var config = DataTableConfiguration()
        config.shouldShowHorizontalScrollBars = true
        XCTAssertTrue(config.shouldShowHorizontalScrollBars)
    }

    func test_canHide_verticalScrollBars() {
        var config = DataTableConfiguration()
        config.shouldShowVerticalScrollBars = false
        XCTAssertFalse(config.shouldShowVerticalScrollBars)
    }

    func test_canSetCustom_sortArrowColor() {
        var config = DataTableConfiguration()
        config.sortArrowTintColor = .red
        XCTAssertEqual(config.sortArrowTintColor, UIColor.red)
    }

    func test_canSet_fixedColumns() {
        var config = DataTableConfiguration()
        config.fixedColumns = DataTableFixedColumnType(leftColumns: 2)
        XCTAssertNotNil(config.fixedColumns)
        XCTAssertEqual(config.fixedColumns?.leftColumns, 2)
    }

    func test_canSet_defaultOrdering() {
        var config = DataTableConfiguration()
        config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        XCTAssertNotNil(config.defaultOrdering)
        XCTAssertEqual(config.defaultOrdering?.index, 1)
        XCTAssertEqual(config.defaultOrdering?.order, .ascending)
    }

    func test_canCustomize_alternatingRowColors() {
        var config = DataTableConfiguration()
        config.highlightedAlternatingRowColors = [.red, .blue, .green]
        XCTAssertEqual(config.highlightedAlternatingRowColors.count, 3)
    }

    // MARK: - Equatable Tests

    func test_defaultConfigurations_areEqual() {
        let config1 = DataTableConfiguration()
        let config2 = DataTableConfiguration()
        XCTAssertEqual(config1, config2)
    }

    func test_configurationsWithDifferentFooterVisibility_areNotEqual() {
        var config1 = DataTableConfiguration()
        var config2 = DataTableConfiguration()
        config2.shouldShowFooter = false
        XCTAssertNotEqual(config1, config2)
    }

    func test_configurationsWithDifferentHeights_areNotEqual() {
        var config1 = DataTableConfiguration()
        var config2 = DataTableConfiguration()
        config2.heightForSectionHeader = 100
        XCTAssertNotEqual(config1, config2)
    }
}

// MARK: - DataTableColumnOrder Tests

class DataTableColumnOrderTests: XCTestCase {

    func test_init_withIndexAndOrder() {
        let order = DataTableColumnOrder(index: 2, order: .descending)
        XCTAssertEqual(order.index, 2)
        XCTAssertEqual(order.order, .descending)
    }

    func test_equalOrders_areEqual() {
        let order1 = DataTableColumnOrder(index: 1, order: .ascending)
        let order2 = DataTableColumnOrder(index: 1, order: .ascending)
        XCTAssertEqual(order1, order2)
    }

    func test_ordersWithDifferentIndices_areNotEqual() {
        let order1 = DataTableColumnOrder(index: 1, order: .ascending)
        let order2 = DataTableColumnOrder(index: 2, order: .ascending)
        XCTAssertNotEqual(order1, order2)
    }

    func test_ordersWithDifferentSortTypes_areNotEqual() {
        let order1 = DataTableColumnOrder(index: 1, order: .ascending)
        let order2 = DataTableColumnOrder(index: 1, order: .descending)
        XCTAssertNotEqual(order1, order2)
    }

    func test_canCreateOrder_forFirstColumn() {
        let order = DataTableColumnOrder(index: 0, order: .ascending)
        XCTAssertEqual(order.index, 0)
    }
}

class DataTableColumnWidthModeTests: XCTestCase {
    func test_columnWidth_fixedStrategyIsClampedByMax() {
        var config = DataTableConfiguration()
        config.minColumnWidth = 50
        config.maxColumnWidth = 60

        let model = DataStructureModel(
            data: [[.string("value")]],
            headerTitles: ["H"],
            useEstimatedColumnWidths: false
        )

        let width = model.columnWidth(index: 0, strategy: .fixed(width: 10), configuration: config)
        XCTAssertEqual(width, 60)
    }

    func test_prefersEstimatedTextWidths_isTrueForEstimatedAndHybrid() {
        let estimated = DataTableColumnWidthMode.fitContentText(
            strategy: .estimatedAverage(averageCharWidth: 7)
        )
        let hybrid = DataTableColumnWidthMode.fitContentText(
            strategy: .hybrid(sampleSize: 10, averageCharWidth: 7)
        )

        XCTAssertTrue(estimated.prefersEstimatedTextWidths)
        XCTAssertTrue(hybrid.prefersEstimatedTextWidths)
    }

    func test_prefersEstimatedTextWidths_isFalseForFixedAndAutoLayout() {
        let fixed = DataTableColumnWidthMode.fixed(width: 120)
        let autoLayout = DataTableColumnWidthMode.fitContentAutoLayout(sample: .all)

        XCTAssertFalse(fixed.prefersEstimatedTextWidths)
        XCTAssertFalse(autoLayout.prefersEstimatedTextWidths)
    }
}

@MainActor
class DataTableCellSizingModeTests: XCTestCase {
    func test_autoLayoutModes_areEqualEvenWithDifferentProviders() {
        let providerA = DataTableCustomCellProvider(
            register: { _ in },
            reuseIdentifierFor: { _ in "A" },
            configure: { _, _, _ in },
            sizingCellFor: { _ in UICollectionViewCell(frame: .zero) }
        )
        let providerB = DataTableCustomCellProvider(
            register: { _ in },
            reuseIdentifierFor: { _ in "B" },
            configure: { _, _, _ in },
            sizingCellFor: { _ in UICollectionViewCell(frame: .zero) }
        )

        XCTAssertEqual(
            DataTableCellSizingMode.autoLayout(provider: providerA),
            DataTableCellSizingMode.autoLayout(provider: providerB)
        )
    }
}

class SearchBarPositionTests: XCTestCase {
    func test_searchBarPosition_casesAreEquatable() {
        XCTAssertEqual(SearchBarPosition.embedded, .embedded)
        XCTAssertEqual(SearchBarPosition.navigationBar, .navigationBar)
        XCTAssertEqual(SearchBarPosition.hidden, .hidden)
        XCTAssertNotEqual(SearchBarPosition.embedded, .hidden)
    }
}
