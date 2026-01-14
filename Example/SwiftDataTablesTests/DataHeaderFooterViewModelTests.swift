//
//  DataHeaderFooterViewModelTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
import UIKit
@testable import SwiftDataTables

class DataHeaderFooterViewModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withDataAndSortType() {
        let viewModel = DataHeaderFooterViewModel(data: "Name", sortType: .ascending)
        XCTAssertEqual(viewModel.data, "Name")
        XCTAssertEqual(viewModel.sortType, .ascending)
    }

    func test_init_withHiddenSortType() {
        let viewModel = DataHeaderFooterViewModel(data: "ID", sortType: .hidden)
        XCTAssertEqual(viewModel.sortType, .hidden)
    }

    func test_init_withEmptyStringData() {
        let viewModel = DataHeaderFooterViewModel(data: "", sortType: .unspecified)
        XCTAssertEqual(viewModel.data, "")
    }

    // MARK: - Image String For Sorting Element Tests

    func test_imageStringForSortingElement_hiddenReturnsNil() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .hidden)
        XCTAssertNil(viewModel.imageStringForSortingElement)
    }

    func test_imageStringForSortingElement_unspecifiedReturnsCorrectString() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .unspecified)
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-unspecified")
    }

    func test_imageStringForSortingElement_ascendingReturnsCorrectString() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .ascending)
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-ascending")
    }

    func test_imageStringForSortingElement_descendingReturnsCorrectString() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .descending)
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-descending")
    }

    // MARK: - Sort Type Mutation Tests

    func test_sortType_canBeChanged() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .unspecified)
        viewModel.sortType = .ascending
        XCTAssertEqual(viewModel.sortType, .ascending)
    }

    func test_changingSortType_updatesImageString() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .unspecified)
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-unspecified")

        viewModel.sortType = .ascending
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-ascending")

        viewModel.sortType = .descending
        XCTAssertEqual(viewModel.imageStringForSortingElement, "column-sort-descending")

        viewModel.sortType = .hidden
        XCTAssertNil(viewModel.imageStringForSortingElement)
    }

    // MARK: - Tint Color Logic Tests

    func test_tintColorForSortingElement_grayWhenDataTableIsNil() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .ascending)
        // dataTable is nil by default
        XCTAssertEqual(viewModel.tintColorForSortingElement, UIColor.gray)
    }

    func test_tintColorForSortingElement_grayWhenSortTypeIsUnspecified() {
        let viewModel = DataHeaderFooterViewModel(data: "Col", sortType: .unspecified)
        XCTAssertEqual(viewModel.tintColorForSortingElement, UIColor.gray)
    }
}

// MARK: - DataCellViewModel Tests

class DataCellViewModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withData() {
        let data = DataTableValueType.string("Test")
        let viewModel = DataCellViewModel(data: data)
        XCTAssertEqual(viewModel.data, data)
    }

    func test_highlighted_isFalseByDefault() {
        let viewModel = DataCellViewModel(data: .int(42))
        XCTAssertFalse(viewModel.highlighted)
    }

    func test_positionTracking_isNilByDefault() {
        let viewModel = DataCellViewModel(data: .int(42))
        XCTAssertNil(viewModel.xPositionRunningTotal)
        XCTAssertNil(viewModel.yPositionRunningTotal)
    }

    func test_virtualHeight_isZeroByDefault() {
        let viewModel = DataCellViewModel(data: .int(42))
        XCTAssertEqual(viewModel.virtualHeight, 0)
    }

    // MARK: - String Representation Tests

    func test_stringRepresentation_matchesData() {
        let viewModel = DataCellViewModel(data: .string("Hello"))
        XCTAssertEqual(viewModel.stringRepresentation, "Hello")
    }

    func test_stringRepresentation_forInt() {
        let viewModel = DataCellViewModel(data: .int(42))
        XCTAssertEqual(viewModel.stringRepresentation, "42")
    }

    func test_stringRepresentation_forNegativeInt() {
        let viewModel = DataCellViewModel(data: .int(-100))
        XCTAssertEqual(viewModel.stringRepresentation, "-100")
    }

    // MARK: - Highlight Tests

    func test_canSetHighlighted_toTrue() {
        let viewModel = DataCellViewModel(data: .int(1))
        viewModel.highlighted = true
        XCTAssertTrue(viewModel.highlighted)
    }

    func test_canToggleHighlighted() {
        let viewModel = DataCellViewModel(data: .int(1))
        viewModel.highlighted = true
        XCTAssertTrue(viewModel.highlighted)
        viewModel.highlighted = false
        XCTAssertFalse(viewModel.highlighted)
    }

    // MARK: - Equatable Tests

    func test_viewModels_withSameDataAndHighlight_areEqual() {
        let vm1 = DataCellViewModel(data: .int(42))
        let vm2 = DataCellViewModel(data: .int(42))
        XCTAssertEqual(vm1, vm2)
    }

    func test_viewModels_withDifferentData_areNotEqual() {
        let vm1 = DataCellViewModel(data: .int(42))
        let vm2 = DataCellViewModel(data: .int(43))
        XCTAssertNotEqual(vm1, vm2)
    }

    func test_viewModels_withDifferentHighlightStates_areNotEqual() {
        let vm1 = DataCellViewModel(data: .int(42))
        let vm2 = DataCellViewModel(data: .int(42))
        vm2.highlighted = true
        XCTAssertNotEqual(vm1, vm2)
    }

    func test_viewModels_sameTypeDifferentValues_areNotEqual() {
        let vm1 = DataCellViewModel(data: .string("A"))
        let vm2 = DataCellViewModel(data: .string("B"))
        XCTAssertNotEqual(vm1, vm2)
    }

    // MARK: - Position Tracking Tests

    func test_canSet_xPosition() {
        let viewModel = DataCellViewModel(data: .int(1))
        viewModel.xPositionRunningTotal = 100.0
        XCTAssertEqual(viewModel.xPositionRunningTotal, 100.0)
    }

    func test_canSet_yPosition() {
        let viewModel = DataCellViewModel(data: .int(1))
        viewModel.yPositionRunningTotal = 200.0
        XCTAssertEqual(viewModel.yPositionRunningTotal, 200.0)
    }

    func test_canSet_virtualHeight() {
        let viewModel = DataCellViewModel(data: .int(1))
        viewModel.virtualHeight = 44.0
        XCTAssertEqual(viewModel.virtualHeight, 44.0)
    }
}
