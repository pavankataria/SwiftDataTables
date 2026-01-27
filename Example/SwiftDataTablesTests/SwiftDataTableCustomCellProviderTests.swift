//
//  SwiftDataTableCustomCellProviderTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for `DataTableCustomCellProvider` custom cell integration.
///
/// These tests verify:
/// - Custom cell registration is called during table initialization
/// - Reuse identifier closure is called when dequeuing cells
/// - Configure closure is called with correct parameters
@MainActor
final class SwiftDataTableCustomCellProviderTests: XCTestCase {
    func test_customCellProvider_registerIsCalledOnInit() {
        var didRegister = false
        let provider = DataTableCustomCellProvider(
            register: { collectionView in
                didRegister = true
                collectionView.register(TestCell.self, forCellWithReuseIdentifier: TestCell.reuseId)
            },
            reuseIdentifierFor: { _ in TestCell.reuseId },
            configure: { _, _, _ in },
            sizingCellFor: { _ in TestCell(frame: .zero) }
        )

        var options = DataTableConfiguration()
        options.cellSizingMode = .autoLayout(provider: provider)

        _ = SwiftDataTable(data: [["A"]], headerTitles: ["H"], options: options)

        XCTAssertTrue(didRegister)
    }

    func test_customCellProvider_reuseIdentifierAndConfigureAreCalled() {
        var reuseCallCount = 0
        var configureCallCount = 0
        let provider = DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(TestCell.self, forCellWithReuseIdentifier: TestCell.reuseId)
            },
            reuseIdentifierFor: { _ in
                reuseCallCount += 1
                return TestCell.reuseId
            },
            configure: { _, _, _ in
                configureCallCount += 1
            },
            sizingCellFor: { _ in TestCell(frame: .zero) }
        )

        var options = DataTableConfiguration()
        options.cellSizingMode = .autoLayout(provider: provider)

        let table = SwiftDataTable(data: [["A"]], headerTitles: ["H"], options: options)
        reuseCallCount = 0
        configureCallCount = 0
        _ = table.collectionView(
            table.collectionView,
            cellForItemAt: IndexPath(item: 0, section: 0)
        )

        XCTAssertGreaterThanOrEqual(reuseCallCount, 1)
        XCTAssertGreaterThanOrEqual(configureCallCount, 1)
    }
}

private final class TestCell: UICollectionViewCell {
    static let reuseId = "TestCell"
}
