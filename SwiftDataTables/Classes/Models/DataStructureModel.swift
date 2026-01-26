//
//  DataStructureModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit


//struct DataTableColumnModel {
//    
//}
public struct DataStructureModel {

    //MARK: - Private Properties
    private var shouldFitTitles: Bool = true
    private var useEstimatedWidths: Bool = false
    var columnCount: Int {
        return headerTitles.count// ?? 0
    }
    //MARK: - Public Properties
    var data = DataTableContent()
    var headerTitles = [String]()
    var footerTitles = [String]()
    var shouldFootersShowSortingElement: Bool = false

    private var columnAverageContentLength = [Float]()

    //MARK: - Lifecycle
    init() {
        self.init(data: DataTableContent(), headerTitles: [String]())
    }

    init(
        data: DataTableContent, headerTitles: [String],
        shouldMakeTitlesFitInColumn: Bool = true,
        shouldDisplayFooterHeaders: Bool = true,
        useEstimatedColumnWidths: Bool = false
        //sortableColumns: [Int] // This will map onto which column can be sortable
        ) {


        self.headerTitles = headerTitles
        self.useEstimatedWidths = useEstimatedColumnWidths
        let unfilteredData = data
        let sanitisedData = unfilteredData.filter({ currentRowData in
            //Trim column count for current row to the number of headers present
            let rowWithPreferredColumnCount = Array(currentRowData.prefix(upTo: self.columnCount))
            return rowWithPreferredColumnCount.count == self.columnCount
        })

        self.data = sanitisedData//sanitisedData
        self.shouldFitTitles = shouldMakeTitlesFitInColumn
        self.columnAverageContentLength = self.processColumnDataAverages(data: self.data)

        if shouldDisplayFooterHeaders {
            self.footerTitles = headerTitles
        }
    }
    
    
    public func averageColumnDataLengthTotal() -> Float {
        return Array(0..<self.headerTitles.count).reduce(0){ $0 + self.averageDataLengthForColumn(index: $1) }
    }
    
    public func averageDataLengthForColumn(
        index: Int) -> Float {
        if self.shouldFitTitles {
            let headerWidth: Float
            if useEstimatedWidths {
                headerWidth = Float(self.headerTitles[index].count) * Float(DataTableConfiguration.defaultAverageCharacterWidth)
            } else {
                headerWidth = Float(self.headerTitles[index].widthOfString(usingFont: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)))
            }
            return max(self.columnAverageContentLength[index], headerWidth)
        }
        return self.columnAverageContentLength[index]
    }

    //extension DataStructureModel {
    //Finds the average content length in each column
    private func processColumnDataAverages(data: DataTableContent) -> [Float] {
        var columnContentAverages = [Float]()

        if useEstimatedWidths {
            // Fast path: Use character count estimation (~7 points per character)
            let estimatedCharWidth: Float = Float(DataTableConfiguration.defaultAverageCharacterWidth)
            for column in 0..<self.headerTitles.count {
                var totalWidth: Float = 0
                for row in data {
                    totalWidth += Float(row[column].stringRepresentation.count) * estimatedCharWidth
                }
                columnContentAverages.append(data.isEmpty ? 1 : totalWidth / Float(data.count))
            }
        } else {
            // Precise path: Use font width measurement (slower)
            for column in 0..<self.headerTitles.count {
                let averageForCurrentColumn = (0..<data.count).reduce(0) {
                    let dataType: DataTableValueType = data[$1][column]
                    return $0 + Int(dataType.stringRepresentation.widthOfString(usingFont: UIFont.systemFont(ofSize: UIFont.labelFontSize)).rounded(.up))
                }
                columnContentAverages.append(data.isEmpty ? 1 : Float(averageForCurrentColumn) / Float(data.count))
            }
        }

        return columnContentAverages
    }
    
    
    public func columnHeaderSortType(for index: Int) -> DataTableSortType {
        guard self.headerTitles[safe: index] != nil else {
            return .hidden
        }
        //Check the configuration object to see what it wants us to display otherwise return default
        return .unspecified
    }

    public func columnFooterSortType(for index: Int) -> DataTableSortType {
        guard self.footerTitles[safe: index] != nil else {
            return .hidden
        }
        //Check the configuration object to see what it wants us to display otherwise return default
        return .unspecified
    }

    func columnWidth(
        index: Int,
        strategy: DataTableColumnWidthStrategy,
        configuration: DataTableConfiguration,
        dataFont: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize),
        headerFont: UIFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    ) -> CGFloat {
        guard self.headerTitles.indices.contains(index) else {
            return configuration.minColumnWidth
        }

        let columnData = self.columnData(for: index)
        let baseContentWidth = self.baseContentWidth(
            for: columnData,
            strategy: strategy,
            dataFont: dataFont
        )

        let paddedWidth = baseContentWidth
            + DataHeaderFooter.Properties.sortIndicatorWidth
            + (DataCell.Properties.horizontalMargin * 2)
        let headerMinimum = self.headerWidth(for: self.headerTitles[index], font: headerFont)
        return clampWidth(paddedWidth, headerMinimum: headerMinimum, minWidth: configuration.minColumnWidth, maxWidth: configuration.maxColumnWidth)
    }

    private func baseContentWidth(for columnData: [DataTableValueType], strategy: DataTableColumnWidthStrategy, dataFont: UIFont) -> CGFloat {
        switch strategy {
        case .fixed(let width):
            return width
        case .estimatedAverage(let averageCharWidth):
            return averageEstimatedWidth(for: columnData, averageCharWidth: averageCharWidth)
        case .hybrid(let sampleSize, let averageCharWidth):
            let estimatedAverage = averageEstimatedWidth(for: columnData, averageCharWidth: averageCharWidth)
            let sampledMax = maximumMeasuredWidth(for: columnData, font: dataFont, sampleSize: sampleSize)
            return max(estimatedAverage, sampledMax)
        case .maxMeasured:
            return maximumMeasuredWidth(for: columnData, font: dataFont, sampleSize: nil)
        case .sampledMax(let sampleSize):
            return maximumMeasuredWidth(for: columnData, font: dataFont, sampleSize: sampleSize)
        case .percentileMeasured(let percentile, let sampleSize):
            let widths = measuredWidths(for: columnData, font: dataFont, sampleSize: sampleSize)
            return percentileWidth(in: widths, percentile: percentile)
        }
    }

    private func columnData(for index: Int) -> [DataTableValueType] {
        return self.data.compactMap { $0[safe: index] }
    }

    private func measuredWidths(for columnData: [DataTableValueType], font: UIFont, sampleSize: Int?) -> [CGFloat] {
        let values = sampledValues(columnData, sampleSize: sampleSize)
        return values.map { value in
            value.stringRepresentation.widthOfString(usingFont: font).rounded(.up)
        }
    }

    private func averageEstimatedWidth(for columnData: [DataTableValueType], averageCharWidth: CGFloat) -> CGFloat {
        guard !columnData.isEmpty else {
            return 0
        }
        let totalWidth = columnData.reduce(CGFloat.zero) { partialResult, value in
            partialResult + (CGFloat(value.stringRepresentation.count) * averageCharWidth)
        }
        return totalWidth / CGFloat(columnData.count)
    }

    private func maximumMeasuredWidth(for columnData: [DataTableValueType], font: UIFont, sampleSize: Int?) -> CGFloat {
        return measuredWidths(for: columnData, font: font, sampleSize: sampleSize).max() ?? 0
    }

    private func percentileWidth(in widths: [CGFloat], percentile: Double) -> CGFloat {
        guard !widths.isEmpty else {
            return 0
        }
        let clampedPercentile = min(max(percentile, 0), 1)
        let sorted = widths.sorted()
        let percentileIndex = Int(round(clampedPercentile * CGFloat(sorted.count - 1)))
        return sorted[percentileIndex]
    }

    private func sampledValues<T>(_ values: [T], sampleSize: Int?) -> [T] {
        guard let sampleSize = sampleSize, sampleSize > 0, values.count > sampleSize else {
            return values
        }

        let strideValue = max(1, Int(ceil(Double(values.count) / Double(sampleSize))))
        var result = [T]()
        var index = 0
        while index < values.count && result.count < sampleSize {
            result.append(values[index])
            index += strideValue
        }
        return result
    }

    private func headerWidth(for title: String, font: UIFont) -> CGFloat {
        return title.widthOfString(usingFont: font)
            + DataHeaderFooter.Properties.sortIndicatorWidth
            + DataHeaderFooter.Properties.labelHorizontalMargin
    }

    private func clampWidth(_ width: CGFloat, headerMinimum: CGFloat, minWidth: CGFloat, maxWidth: CGFloat?) -> CGFloat {
        let minClamped = max(width, minWidth)
        let maxClamped = maxWidth.map { min(minClamped, $0) } ?? minClamped
        return max(maxClamped, headerMinimum)
    }
}

extension DataTableColumnWidthStrategy {
    var prefersEstimation: Bool {
        switch self {
        case .estimatedAverage, .hybrid:
            return true
        default:
            return false
        }
    }
}
