//
//  DataTableTextLayout.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

/// Defines how text content is displayed within data table cells.
///
/// `DataTableTextLayout` controls whether cell text is truncated to a single line
/// or allowed to wrap across multiple lines, affecting both appearance and row height.
///
/// ## Usage
///
/// Configure via `DataTableConfiguration`:
/// ```swift
/// var config = DataTableConfiguration()
///
/// // Single line with tail truncation (default)
/// config.textLayout = .singleLine()
///
/// // Single line with middle truncation
/// config.textLayout = .singleLine(truncation: .byTruncatingMiddle)
///
/// // Multi-line wrapping
/// config.textLayout = .wrap
/// ```
///
/// ## Row Height Considerations
///
/// When using `.wrap`, consider also configuring `rowHeightMode`:
/// ```swift
/// config.textLayout = .wrap
/// config.rowHeightMode = .automatic(estimated: 60)
/// ```
///
/// This enables dynamic row heights that expand to fit wrapped content.
public enum DataTableTextLayout: Equatable {

    /// Displays text on a single line with truncation.
    ///
    /// - Parameter truncation: The truncation mode to apply when text exceeds
    ///   the available width. Defaults to `.byTruncatingTail`.
    ///
    /// Available truncation modes:
    /// - `.byTruncatingTail`: Truncates end of text ("Hello Wor...")
    /// - `.byTruncatingHead`: Truncates beginning ("...llo World")
    /// - `.byTruncatingMiddle`: Truncates middle ("Hel...orld")
    ///
    /// Example:
    /// ```swift
    /// // Default tail truncation
    /// config.textLayout = .singleLine()
    ///
    /// // Middle truncation for file paths
    /// config.textLayout = .singleLine(truncation: .byTruncatingMiddle)
    /// ```
    case singleLine(truncation: NSLineBreakMode = .byTruncatingTail)

    /// Allows text to wrap across multiple lines.
    ///
    /// When wrapping is enabled, cells expand vertically to accommodate
    /// their content. For best results, pair with automatic row heights:
    /// ```swift
    /// config.textLayout = .wrap
    /// config.rowHeightMode = .automatic(estimated: 60)
    /// ```
    ///
    /// - Note: Wrapping may impact performance with large datasets.
    ///   Consider using `.automatic` row height mode with appropriate
    ///   prefetch settings for optimal scrolling performance.
    case wrap
}
