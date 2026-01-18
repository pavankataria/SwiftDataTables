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
            let headerWidth: Float = useEstimatedWidths
                ? Float(self.headerTitles[index].count) * 7.0
                : Float(self.headerTitles[index].count)
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
            let estimatedCharWidth: Float = 7.0
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
        return .hidden
    }
}
