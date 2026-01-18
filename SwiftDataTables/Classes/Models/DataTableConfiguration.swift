//
//  DataTableConfiguration.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

public enum DataStyles {
    
    public enum Colors {
        
        public nonisolated(unsafe) static var highlightedFirstColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1),
                              darkColor: UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1),
                              defaultColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1))
        }()
        
        public nonisolated(unsafe) static var highlightedSecondColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                              darkColor: UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
                              defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))
        }()
        
        public nonisolated(unsafe) static var unhighlightedFirstColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                              darkColor: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1),
                              defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))
        }()
        
        public nonisolated(unsafe) static var unhighlightedSecondColor: UIColor = {
            return setupColor(normalColor: .white,
                              darkColor: UIColor(red: 0.03, green: 0.03, blue: 0.03, alpha: 1),
                              defaultColor: .white)
        }()
    }
}

public let Style = DataStyles.self

private func setupColor(normalColor: UIColor, darkColor: UIColor, defaultColor: UIColor) -> UIColor {
    if #available(iOS 13, *) {
        return UIColor.init { (trait) -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return darkColor
            } else {
                return normalColor
            }
        }
    } else {
        return defaultColor
    }
}

public struct DataTableColumnOrder: Equatable {
    //MARK: - Properties
    let index: Int
    let order: DataTableSortType
    public init(index: Int, order: DataTableSortType){
        self.index = index
        self.order = order
    }
}
public struct DataTableConfiguration: Equatable {
    public static let defaultAverageCharacterWidth: CGFloat = 7.0
    public static let defaultColumnWidthStrategy: DataTableColumnWidthStrategy = .estimated(averageCharWidth: DataTableConfiguration.defaultAverageCharacterWidth)

    private var columnWidthStrategyWasSetExplicitly = false

    public var defaultOrdering: DataTableColumnOrder? = nil
    public var heightForSectionFooter: CGFloat = 44
    public var heightForSectionHeader: CGFloat = 44
    public var heightForSearchView: CGFloat = 60
    public var heightOfInterRowSpacing: CGFloat = 1

    public var shouldShowFooter: Bool = true
    public var shouldShowSearchSection: Bool = true
    public var shouldSearchHeaderFloat: Bool = false
    public var shouldSectionFootersFloat: Bool = true
    public var shouldSectionHeadersFloat: Bool = true
    public var shouldContentWidthScaleToFillFrame: Bool = true
    
    public var shouldShowVerticalScrollBars: Bool = true
    public var shouldShowHorizontalScrollBars: Bool = false

    public var sortArrowTintColor: UIColor = UIColor.blue
    
    public var shouldSupportRightToLeftInterfaceDirection: Bool = true
    
    public var highlightedAlternatingRowColors = [
        DataStyles.Colors.highlightedFirstColor,
        DataStyles.Colors.highlightedSecondColor
    ]
    public var unhighlightedAlternatingRowColors = [
        DataStyles.Colors.unhighlightedFirstColor,
        DataStyles.Colors.unhighlightedSecondColor
    ]
    
    public var fixedColumns: DataTableFixedColumnType? = nil

    public var columnWidthStrategy: DataTableColumnWidthStrategy = DataTableConfiguration.defaultColumnWidthStrategy {
        didSet {
            columnWidthStrategyWasSetExplicitly = true
        }
    }
    public var minColumnWidth: CGFloat = 70
    public var maxColumnWidth: CGFloat? = nil
    public var columnWidthProvider: ((Int, [DataTableValueType], String, UIFont) -> CGFloat)? = nil

    @available(*, deprecated, message: "Use columnWidthStrategy instead.")
    public var useEstimatedColumnWidths: Bool = true

    var resolvedColumnWidthStrategy: DataTableColumnWidthStrategy {
        if columnWidthStrategyWasSetExplicitly {
            return columnWidthStrategy
        }
        return useEstimatedColumnWidths ? columnWidthStrategy : .maxMeasured
    }

    public init(){

    }
}

extension DataTableConfiguration {
    public static func == (lhs: DataTableConfiguration, rhs: DataTableConfiguration) -> Bool {
        return lhs.defaultOrdering == rhs.defaultOrdering &&
        lhs.heightForSectionFooter == rhs.heightForSectionFooter &&
        lhs.heightForSectionHeader == rhs.heightForSectionHeader &&
        lhs.heightForSearchView == rhs.heightForSearchView &&
        lhs.heightOfInterRowSpacing == rhs.heightOfInterRowSpacing &&
        lhs.shouldShowFooter == rhs.shouldShowFooter &&
        lhs.shouldShowSearchSection == rhs.shouldShowSearchSection &&
        lhs.shouldSearchHeaderFloat == rhs.shouldSearchHeaderFloat &&
        lhs.shouldSectionFootersFloat == rhs.shouldSectionFootersFloat &&
        lhs.shouldSectionHeadersFloat == rhs.shouldSectionHeadersFloat &&
        lhs.shouldContentWidthScaleToFillFrame == rhs.shouldContentWidthScaleToFillFrame &&
        lhs.shouldShowVerticalScrollBars == rhs.shouldShowVerticalScrollBars &&
        lhs.shouldShowHorizontalScrollBars == rhs.shouldShowHorizontalScrollBars &&
        lhs.sortArrowTintColor == rhs.sortArrowTintColor &&
        lhs.shouldSupportRightToLeftInterfaceDirection == rhs.shouldSupportRightToLeftInterfaceDirection &&
        lhs.highlightedAlternatingRowColors == rhs.highlightedAlternatingRowColors &&
        lhs.unhighlightedAlternatingRowColors == rhs.unhighlightedAlternatingRowColors &&
        lhs.fixedColumns == rhs.fixedColumns &&
        lhs.useEstimatedColumnWidths == rhs.useEstimatedColumnWidths &&
        lhs.columnWidthStrategy == rhs.columnWidthStrategy &&
        lhs.minColumnWidth == rhs.minColumnWidth &&
        lhs.maxColumnWidth == rhs.maxColumnWidth
    }
}
