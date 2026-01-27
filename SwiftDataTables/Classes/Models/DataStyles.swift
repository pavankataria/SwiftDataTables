//
//  DataStyles.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 28/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

/// Provides default styling configuration for data table appearance.
///
/// `DataStyles` contains color definitions used throughout the data table
/// for alternating row backgrounds, highlighting, and other visual elements.
/// These colors automatically adapt to light and dark mode on iOS 13+.
///
/// ## Usage
///
/// Access colors through the `Colors` nested enum:
/// ```swift
/// let highlightColor = DataStyles.Colors.highlightedFirstColor
/// ```
///
/// Or use the convenience alias:
/// ```swift
/// let highlightColor = Style.Colors.highlightedFirstColor
/// ```
///
/// ## Customization
///
/// These static colors can be overridden globally:
/// ```swift
/// DataStyles.Colors.highlightedFirstColor = .systemBlue.withAlphaComponent(0.2)
/// ```
///
/// For per-table customization, use `DataTableConfiguration`:
/// ```swift
/// var config = DataTableConfiguration()
/// config.highlightedAlternatingRowColors = [.red, .blue]
/// ```
public enum DataStyles {

    /// Color definitions for data table styling.
    ///
    /// All colors automatically adapt to light and dark appearance modes
    /// when running on iOS 13 or later.
    public enum Colors {

        /// Primary background color for highlighted (sorted column) rows.
        ///
        /// - Light mode: Light gray (#F0F0F0)
        /// - Dark mode: Dark gray (#292929)
        public nonisolated(unsafe) static var highlightedFirstColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1),
                              darkColor: UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1),
                              defaultColor: UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1))
        }()

        /// Secondary background color for highlighted (sorted column) rows.
        ///
        /// Used for alternating row striping in highlighted columns.
        /// - Light mode: Very light gray (#F8F8F8)
        /// - Dark mode: Darker gray (#212121)
        public nonisolated(unsafe) static var highlightedSecondColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                              darkColor: UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
                              defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))
        }()

        /// Primary background color for unhighlighted (non-sorted column) rows.
        ///
        /// - Light mode: Very light gray (#F8F8F8)
        /// - Dark mode: Near black (#0F0F0F)
        public nonisolated(unsafe) static var unhighlightedFirstColor: UIColor = {
            return setupColor(normalColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1),
                              darkColor: UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1),
                              defaultColor: UIColor(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1))
        }()

        /// Secondary background color for unhighlighted (non-sorted column) rows.
        ///
        /// Used for alternating row striping in unhighlighted columns.
        /// - Light mode: White
        /// - Dark mode: Nearly black (#080808)
        public nonisolated(unsafe) static var unhighlightedSecondColor: UIColor = {
            return setupColor(normalColor: .white,
                              darkColor: UIColor(red: 0.03, green: 0.03, blue: 0.03, alpha: 1),
                              defaultColor: .white)
        }()
    }
}

/// Convenience alias for accessing `DataStyles`.
///
/// Allows shorter syntax when accessing style definitions:
/// ```swift
/// let color = Style.Colors.highlightedFirstColor
/// ```
public let Style = DataStyles.self

// MARK: - Private Helpers

/// Creates a dynamic color that adapts to the current user interface style.
///
/// - Parameters:
///   - normalColor: Color to use in light mode.
///   - darkColor: Color to use in dark mode.
///   - defaultColor: Fallback color for iOS versions before 13.
/// - Returns: A UIColor that automatically adapts to appearance changes.
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
