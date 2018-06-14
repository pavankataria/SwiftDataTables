//
//  xyPositionTrackable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

protocol VirtualPositionTrackable {
    var xPositionRunningTotal: CGFloat? { get set }
    var yPositionRunningTotal: CGFloat? { get set }
    var virtualHeight: CGFloat { get set }
    
    var maxY: CGFloat { get }
}
extension VirtualPositionTrackable {
    var maxY: CGFloat {
        return self.yPositionRunningTotal ?? 0 + self.virtualHeight
    }
}
//extension VirtualPositionTrackable {
//    mutating func setXPositionRunningTotalCache(x: CGFloat){
//        self.xPositionRunningTotal = x
//    }
//}
