//
//  DataCellLayoutAttributes.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

open class DataCellLayoutAttributes: UICollectionViewLayoutAttributes {

    //MARK: - Properties
    var xPositionRunningTotal: CGFloat? = nil
    var yPositionRunningTotal: CGFloat? = nil
    
    //MARK: - Lifecycle
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! DataCellLayoutAttributes
        copy.xPositionRunningTotal = self.xPositionRunningTotal
        copy.yPositionRunningTotal = self.yPositionRunningTotal
        return copy
    }
}
