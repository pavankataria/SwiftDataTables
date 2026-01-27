//
//  SwiftDataTable+Extensions.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 24/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

// MARK: - IndexPath Extensions

public extension IndexPath {

    /// Provides convenient access to the first index component.
    ///
    /// Used for single-dimensional index paths where only one index is needed,
    /// such as column indices in the data table layout.
    ///
    /// Example:
    /// ```swift
    /// let columnPath = IndexPath(index: 5)
    /// print(columnPath.index) // 5
    /// ```
    var index: Int {
        return self[0]
    }
}

// MARK: - Collection Extensions

extension Collection where Indices.Iterator.Element == Index {

    /// Safely accesses an element at the given index.
    ///
    /// Returns `nil` if the index is out of bounds instead of crashing.
    ///
    /// - Parameter index: The index of the element to access.
    /// - Returns: The element at the index, or `nil` if out of bounds.
    ///
    /// Example:
    /// ```swift
    /// let array = [1, 2, 3]
    /// array[safe: 1]  // Optional(2)
    /// array[safe: 10] // nil
    /// ```
    subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UIScrollView Extensions

extension UIScrollView {

    /// Resets the scroll position to the top-left corner.
    ///
    /// Accounts for content insets to position at the true visual origin.
    func resetScrollPositionToTop() {
        self.contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
    }
}

// MARK: - String Extensions

extension String {

    /// Calculates the rendered width of the string using the specified font.
    ///
    /// Used for column width calculations when using measured width strategies.
    ///
    /// - Parameter font: The font to use for measurement.
    /// - Returns: The width in points required to render the string.
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
