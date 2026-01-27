//
//  SearchBarPosition.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import Foundation

/// Controls where the search bar is displayed in relation to the data table.
///
/// `SearchBarPosition` determines the search bar's location and behavior,
/// allowing integration with iOS navigation patterns or embedding directly
/// within the table.
///
/// ## Usage
///
/// Configure via `DataTableConfiguration`:
/// ```swift
/// var config = DataTableConfiguration()
///
/// // Embedded within the table (default)
/// config.searchBarPosition = .embedded
///
/// // In the navigation bar
/// config.searchBarPosition = .navigationBar
///
/// // Hidden entirely
/// config.searchBarPosition = .hidden
/// ```
///
/// ## Navigation Bar Integration
///
/// When using `.navigationBar`, the search bar automatically attaches to
/// the parent view controller's `navigationItem`. Ensure your view controller
/// is embedded in a `UINavigationController`:
///
/// ```swift
/// let tableVC = DataTableViewController()
/// var config = DataTableConfiguration()
/// config.searchBarPosition = .navigationBar
/// tableVC.dataTable = SwiftDataTable(data: data, options: config)
///
/// let nav = UINavigationController(rootViewController: tableVC)
/// ```
public enum SearchBarPosition: Equatable {

    /// Search bar is embedded within the data table view.
    ///
    /// The search bar appears at the top of the table content and scrolls
    /// with the table (unless `shouldSearchHeaderFloat` is enabled).
    /// This is the default behavior.
    ///
    /// Configure floating behavior:
    /// ```swift
    /// config.searchBarPosition = .embedded
    /// config.shouldSearchHeaderFloat = true  // Keeps search visible during scroll
    /// ```
    case embedded

    /// Search bar is placed in the navigation bar using `UISearchController`.
    ///
    /// Automatically attaches to the parent view controller's `navigationItem`.
    /// Provides iOS-standard search behavior including:
    /// - Large title collapse integration
    /// - Pull-to-reveal search
    /// - Standard iOS search animations
    ///
    /// Requirements:
    /// - View controller must be in a `UINavigationController`
    /// - Navigation bar must be visible
    ///
    /// - Note: When using this option, `shouldShowSearchSection` and
    ///   `shouldSearchHeaderFloat` configuration options are ignored.
    case navigationBar

    /// No search bar is displayed.
    ///
    /// Use when search functionality is not needed or when implementing
    /// custom search UI external to the data table.
    ///
    /// This is equivalent to setting `shouldShowSearchSection = false`
    /// but provides clearer intent.
    case hidden
}
