//
//  DataTableFixedColumnType.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 18/06/2019.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// Indicates which side a fixed column is positioned on.
///
/// Used internally to determine rendering and scroll behavior for frozen columns.
public enum DataTableFixedColumnSideType {

    /// Column is fixed on the left side of the table.
    case left

    /// Column is fixed on the right side of the table.
    case right
}

/// Configuration for fixed (frozen) columns that remain visible during horizontal scrolling.
///
/// Fixed columns stay in place while other columns scroll horizontally, useful for
/// keeping identifier columns visible. You can fix columns on the left, right, or both sides.
///
/// ## Usage
///
/// ```swift
/// var config = DataTableConfiguration()
///
/// // Fix first 2 columns on left
/// config.fixedColumns = DataTableFixedColumnType(leftColumns: 2)
///
/// // Fix last column on right
/// config.fixedColumns = DataTableFixedColumnType(rightColumns: 1)
///
/// // Fix columns on both sides
/// config.fixedColumns = DataTableFixedColumnType(leftColumns: 1, rightColumns: 1)
/// ```
///
/// ## Behavior
///
/// - Fixed columns overlay scrollable content with a subtle shadow
/// - Left-fixed columns anchor to the leading edge
/// - Right-fixed columns anchor to the trailing edge
/// - The remaining columns scroll normally between fixed regions
///
/// ## Limitations
///
/// - Total fixed columns must be less than total columns
/// - Large numbers of fixed columns may reduce scrollable area significantly
public class DataTableFixedColumnType: NSObject {
    
    //MARK: - Properties
    public let leftColumns: Int
    public let rightColumns: Int

    //MARK: - Lifecycle
    public init(leftColumns: Int, rightColumns: Int){
        self.leftColumns = leftColumns
        self.rightColumns = rightColumns
    }
    
    public convenience init(leftColumns: Int) {
        self.init(leftColumns: leftColumns, rightColumns: 0)
    }
    
    public convenience init(rightColumns: Int) {
        self.init(leftColumns: 0, rightColumns: rightColumns)
    }
}

extension DataTableFixedColumnType {
    public func hitTest(_ columnIndex: Int, totalTableColumnCount: Int) -> DataTableFixedColumnSideType? {
        if columnIndex < leftColumns {
            return .left
        }
        else if columnIndex >= totalTableColumnCount - rightColumns {
            return .right
        }
        return nil
    }
}
