//
//  DataTableConfiguration.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

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
    public var defaultOrdering: DataTableColumnOrder? = nil
    public var heightForSectionFooter: CGFloat = 44
    public var heightForSectionHeader: CGFloat = 44
    public var heightForSearchView: CGFloat = 60
    public var heightOfInterRowSpacing: CGFloat = 1

    public var shouldShowDataBorders: Bool = false
    public var shouldShowHeaderFooterBorders: Bool = false
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
        UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1),
        UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1)
    ]
    public var unhighlightedAlternatingRowColors = [
        UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
        .white
    ]
    
    public var fixedColumns: DataTableFixedColumnType? = nil

    public var headerFooterBackgroundColor: UIColor = UIColor.white

    public var dataTextAlignment: NSTextAlignment = .natural
    public var headerFooterTextAlignment: NSTextAlignment = .natural
    
    public init(){
        
    }
}
