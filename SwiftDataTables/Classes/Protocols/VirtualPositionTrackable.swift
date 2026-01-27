//
//  VirtualPositionTrackable.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// Internal protocol for tracking virtual position in layout calculations.
///
/// This protocol is used by the layout engine to track cumulative positions
/// during column and row layout. It enables efficient layout calculation
/// without creating actual frames until needed.
///
/// ## Properties
///
/// - `xPositionRunningTotal`: Cumulative horizontal position.
/// - `yPositionRunningTotal`: Cumulative vertical position.
/// - `virtualHeight`: The height this element occupies.
/// - `maxY`: Computed maximum Y coordinate (bottom edge).
@MainActor
protocol VirtualPositionTrackable {

    /// The cumulative horizontal position from the leading edge.
    var xPositionRunningTotal: CGFloat? { get set }

    /// The cumulative vertical position from the top edge.
    var yPositionRunningTotal: CGFloat? { get set }

    /// The height this element occupies in the layout.
    var virtualHeight: CGFloat { get set }

    /// The maximum Y coordinate (bottom edge) of this element.
    var maxY: CGFloat { get }
}

extension VirtualPositionTrackable {

    /// Default implementation calculates maxY from position and height.
    var maxY: CGFloat {
        return self.yPositionRunningTotal ?? 0 + self.virtualHeight
    }
}
