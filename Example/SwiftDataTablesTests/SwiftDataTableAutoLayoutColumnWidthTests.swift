//
//  SwiftDataTableAutoLayoutColumnWidthTests.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import XCTest
import UIKit
@testable import SwiftDataTables

/// Tests for AutoLayout-based column width calculation modes.
///
/// These tests verify the `DataTableAutoLayoutWidthSample` strategies for
/// determining column widths when using custom AutoLayout cells:
/// - `.all`: Measures all rows to find the maximum content width
/// - `.sampledMax(sampleSize:)`: Measures a deterministic sample and uses the max
/// - `.percentile(_:sampleSize:)`: Measures a sample and uses a percentile value
///
/// The tests use a monospaced font cell (`AutoLayoutTestCell`) to ensure
/// consistent width measurements across different content lengths.
@MainActor
final class SwiftDataTableAutoLayoutColumnWidthTests: XCTestCase {
    func test_autoLayoutColumnWidth_all_usesMaxMeasuredWidth() {
        let values = ["MMMM", "MMMMMMMM", "MMMMMMMMMMMM"]
        let table = makeTable(values: values, sample: .all)
        table.calculateColumnWidths()

        let measured = values.map(measuredWidth).max() ?? 0
        let expected = expectedAutoLayoutWidth(header: "H", contentWidth: measured, config: table.options)

        XCTAssertEqual(table.widthForColumn(index: 0), expected, accuracy: 1.0)
    }

    func test_autoLayoutColumnWidth_sampledMax_usesDeterministicSample() {
        let values = [
            "MMMM", "MMMMMMMM", "MMMMMMMMMMMM",
            "MMMMMMMMMMMMMMMM", "MMMMMMMMMMMMMMMMMMMM"
        ]
        let sampleSize = 2
        let table = makeTable(values: values, sample: .sampledMax(sampleSize: sampleSize))
        table.calculateColumnWidths()

        let sampled = sampledValues(values: values, sampleSize: sampleSize)
        let sampledMax = sampled.map(measuredWidth).max() ?? 0
        let expected = expectedAutoLayoutWidth(header: "H", contentWidth: sampledMax, config: table.options)

        XCTAssertEqual(table.widthForColumn(index: 0), expected, accuracy: 1.0)
    }

    func test_autoLayoutColumnWidth_percentile_usesSampledPercentile() {
        let values = [
            "MMMM", "MMMMMMMM", "MMMMMMMMMMMM",
            "MMMMMMMMMMMMMMMM", "MMMMMMMMMMMMMMMMMMMM"
        ]
        let sampleSize = 3
        let percentile = 0.5
        let table = makeTable(values: values, sample: .percentile(percentile, sampleSize: sampleSize))
        table.calculateColumnWidths()

        let sampled = sampledValues(values: values, sampleSize: sampleSize)
        let widths = sampled.map(measuredWidth).sorted()
        let index = Int(round(percentile * CGFloat(widths.count - 1)))
        let percentileWidth = widths[index]
        let expected = expectedAutoLayoutWidth(header: "H", contentWidth: percentileWidth, config: table.options)

        XCTAssertEqual(table.widthForColumn(index: 0), expected, accuracy: 1.0)
    }
}

@MainActor
private func makeTable(values: [String], sample: DataTableAutoLayoutWidthSample) -> SwiftDataTable {
    let provider = DataTableCustomCellProvider(
        register: { collectionView in
            collectionView.register(AutoLayoutTestCell.self, forCellWithReuseIdentifier: AutoLayoutTestCell.reuseId)
        },
        reuseIdentifierFor: { _ in AutoLayoutTestCell.reuseId },
        configure: { cell, value, _ in
            (cell as? AutoLayoutTestCell)?.configure(text: value.stringRepresentation)
        },
        sizingCellFor: { _ in AutoLayoutTestCell(frame: .zero) }
    )

    var options = DataTableConfiguration()
    options.cellSizingMode = .autoLayout(provider: provider)
    options.columnWidthMode = .fitContentAutoLayout(sample: sample)
    options.minColumnWidth = 0

    return SwiftDataTable(
        data: values.map { [DataTableValueType.string($0)] },
        headerTitles: ["H"],
        options: options
    )
}

private func measuredWidth(for text: String) -> CGFloat {
    let width = text.widthOfString(usingFont: AutoLayoutTestCell.font)
    return ceil(width)
}

private func expectedAutoLayoutWidth(header: String, contentWidth: CGFloat, config: DataTableConfiguration) -> CGFloat {
    let headerMinimum = header.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize))
        + DataHeaderFooter.Properties.sortIndicatorWidth
        + DataHeaderFooter.Properties.labelHorizontalMargin
    let minClamped = max(contentWidth, config.minColumnWidth)
    let maxClamped = config.maxColumnWidth.map { min(minClamped, $0) } ?? minClamped
    return max(maxClamped, headerMinimum)
}

private func sampledValues<T>(values: [T], sampleSize: Int) -> [T] {
    guard sampleSize > 0, values.count > sampleSize else {
        return values
    }
    let strideValue = max(1, Int(ceil(Double(values.count) / Double(sampleSize))))
    var result: [T] = []
    var index = 0
    while index < values.count && result.count < sampleSize {
        result.append(values[index])
        index += strideValue
    }
    return result
}

private final class AutoLayoutTestCell: UICollectionViewCell {
    static let reuseId = "AutoLayoutTestCell"
    static let font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = Self.font
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        label.text = text
    }
}
