//
//  DataStructureModelColumnWidthTests.swift
//  SwiftDataTablesTests
//
//  Created for SwiftDataTables.
//

import XCTest
import UIKit
@testable import SwiftDataTables

final class DataStructureModelColumnWidthTests: XCTestCase {
    func test_columnWidth_estimatedAverage_usesAverageCharWidth() {
        let values = ["aa", "bbbb"]
        let model = makeModel(header: "H", values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0

        let averageCharWidth: CGFloat = 10
        let base = averageEstimatedWidth(values: values, averageCharWidth: averageCharWidth)
        let expected = expectedWidth(header: "H", baseContentWidth: base, config: config)

        let width = model.columnWidth(
            index: 0,
            strategy: .estimatedAverage(averageCharWidth: averageCharWidth),
            configuration: config
        )

        XCTAssertEqual(width, expected, accuracy: 0.5)
    }

    func test_columnWidth_maxMeasured_usesLongestMeasuredWidth() {
        let values = ["a", "bbbb", "cc"]
        let model = makeModel(header: "H", values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0

        let base = values.map(measuredWidth).max() ?? 0
        let expected = expectedWidth(header: "H", baseContentWidth: base, config: config)

        let width = model.columnWidth(
            index: 0,
            strategy: .maxMeasured,
            configuration: config
        )

        XCTAssertEqual(width, expected, accuracy: 0.5)
    }

    func test_columnWidth_sampledMax_usesDeterministicSample() {
        let values = [
            "a", "bb", "ccc", "dddd", "eeeee",
            "ffffff", "ggggggg", "hhhhhhhh", "iiiiiiiii", "jjjjjjjjjj"
        ]
        let model = makeModel(header: "H", values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0

        let sampleSize = 3
        let sampled = sampledValues(values: values, sampleSize: sampleSize)
        let sampledMax = sampled.map(measuredWidth).max() ?? 0
        let expected = expectedWidth(header: "H", baseContentWidth: sampledMax, config: config)

        let width = model.columnWidth(
            index: 0,
            strategy: .sampledMax(sampleSize: sampleSize),
            configuration: config
        )

        let fullMax = values.map(measuredWidth).max() ?? 0
        XCTAssertLessThan(sampledMax, fullMax)
        XCTAssertEqual(width, expected, accuracy: 0.5)
    }

    func test_columnWidth_percentileMeasured_usesPercentileOfSample() {
        let values = [
            "a", "bb", "ccc", "dddd", "eeeee",
            "ffffff", "ggggggg", "hhhhhhhh", "iiiiiiiii", "jjjjjjjjjj"
        ]
        let model = makeModel(header: "H", values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0

        let sampleSize = 4
        let percentile = 0.5
        let sampled = sampledValues(values: values, sampleSize: sampleSize)
        let widths = sampled.map(measuredWidth).sorted()
        let index = Int(round(percentile * CGFloat(widths.count - 1)))
        let base = widths[index]
        let expected = expectedWidth(header: "H", baseContentWidth: base, config: config)

        let width = model.columnWidth(
            index: 0,
            strategy: .percentileMeasured(percentile: percentile, sampleSize: sampleSize),
            configuration: config
        )

        XCTAssertEqual(width, expected, accuracy: 0.5)
    }

    func test_columnWidth_hybrid_usesMaxOfEstimatedAndSampled() {
        let values = ["a", "bb"]
        let model = makeModel(header: "H", values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0

        let averageCharWidth: CGFloat = 40
        let estimated = averageEstimatedWidth(values: values, averageCharWidth: averageCharWidth)
        let sampled = sampledValues(values: values, sampleSize: 1).map(measuredWidth).max() ?? 0
        let base = max(estimated, sampled)
        let expected = expectedWidth(header: "H", baseContentWidth: base, config: config)

        let width = model.columnWidth(
            index: 0,
            strategy: .hybrid(sampleSize: 1, averageCharWidth: averageCharWidth),
            configuration: config
        )

        XCTAssertEqual(width, expected, accuracy: 0.5)
    }

    func test_columnWidth_headerMinimumOverridesMaxWidth() {
        let values = ["a"]
        let header = "VeryLongHeaderTitle"
        let model = makeModel(header: header, values: values)
        var config = DataTableConfiguration()
        config.minColumnWidth = 0
        config.maxColumnWidth = 50

        let width = model.columnWidth(
            index: 0,
            strategy: .fixed(width: 10),
            configuration: config
        )

        let headerMinimum = header.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize))
            + DataHeaderFooter.Properties.sortIndicatorWidth
            + DataHeaderFooter.Properties.labelHorizontalMargin
        XCTAssertGreaterThan(headerMinimum, 50)
        XCTAssertEqual(width, headerMinimum, accuracy: 0.5)
    }
}

private func makeModel(header: String, values: [String]) -> DataStructureModel {
    let rows = values.map { [DataTableValueType.string($0)] }
    return DataStructureModel(data: rows, headerTitles: [header], useEstimatedColumnWidths: false)
}

private func averageEstimatedWidth(values: [String], averageCharWidth: CGFloat) -> CGFloat {
    guard !values.isEmpty else { return 0 }
    let total = values.reduce(CGFloat.zero) { $0 + (CGFloat($1.count) * averageCharWidth) }
    return total / CGFloat(values.count)
}

private func measuredWidth(for value: String) -> CGFloat {
    let font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    return value.widthOfString(usingFont: font).rounded(.up)
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

private func expectedWidth(header: String, baseContentWidth: CGFloat, config: DataTableConfiguration) -> CGFloat {
    let paddedWidth = baseContentWidth
        + DataHeaderFooter.Properties.sortIndicatorWidth
        + (DataCell.Properties.horizontalMargin * 2)
    let headerMinimum = header.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize))
        + DataHeaderFooter.Properties.sortIndicatorWidth
        + DataHeaderFooter.Properties.labelHorizontalMargin
    let minClamped = max(paddedWidth, config.minColumnWidth)
    let maxClamped = config.maxColumnWidth.map { min(minClamped, $0) } ?? minClamped
    return max(maxClamped, headerMinimum)
}
