//
//  DataCellLayoutAttributes.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Custom layout attributes for data cells that track virtual position.
///
/// `DataCellLayoutAttributes` extends `UICollectionViewLayoutAttributes` to include
/// position tracking properties used by the layout engine for efficient calculations.
///
/// ## Usage
///
/// These attributes are created by `SwiftDataTableLayout` and passed to cells
/// during layout. The additional properties help track cumulative positions
/// without recalculating from scratch.
///
/// ## Copy Semantics
///
/// The `copy(with:)` method ensures that position tracking properties are
/// preserved when the collection view copies layout attributes.
open class DataCellLayoutAttributes: UICollectionViewLayoutAttributes {

    // MARK: - Properties

    /// The cumulative horizontal position from the leading edge.
    var xPositionRunningTotal: CGFloat? = nil

    /// The cumulative vertical position from the top edge.
    var yPositionRunningTotal: CGFloat? = nil

    // MARK: - NSCopying

    /// Creates a copy of the layout attributes including position tracking.
    ///
    /// - Parameter zone: The memory zone (unused, for compatibility).
    /// - Returns: A copy with all properties including position tracking.
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! DataCellLayoutAttributes
        copy.xPositionRunningTotal = self.xPositionRunningTotal
        copy.yPositionRunningTotal = self.yPositionRunningTotal
        return copy
    }
}
