//
//  DataTableAnimation.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/01/2026.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation

/// Animation behavior for data table updates.
///
/// `DataTableAnimation` controls how changes are animated when updating
/// table content through methods like `setData` and `reload`.
///
/// ## Usage
///
/// ```swift
/// // Animate changes (default)
/// table.setData(newData, animatingDifferences: true)
///
/// // Skip animation for instant updates
/// table.setData(newData, animatingDifferences: false)
/// ```
public enum DataTableAnimation {

    /// Uses the system default animation for insertions, deletions, and moves.
    ///
    /// The collection view determines appropriate animations based on
    /// the type of change (fade for updates, slide for insertions/deletions).
    case automatic

    /// No animation; changes appear instantly.
    ///
    /// Use for bulk updates or when animation would be disorienting.
    case none
}
