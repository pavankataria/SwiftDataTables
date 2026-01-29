//
//  DataHeaderFooterViewModel.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import Foundation
import UIKit

/// Indicates whether a header/footer view model is for the top header or bottom footer.
///
/// Used to determine sorting indicator visibility and tap behavior based on configuration.
public enum HeaderFooterType {

    /// The view model is for a column header at the top of the table.
    case header

    /// The view model is for a column footer at the bottom of the table.
    case footer
}

/// View model for column headers and footers in a SwiftDataTable.
///
/// `DataHeaderFooterViewModel` manages the state and presentation of column headers
/// and footers, including the column title, sort state, and sorting indicator.
///
/// ## Responsibilities
///
/// - Stores the column title text
/// - Tracks the current sort state for the column
/// - Provides images and colors for the sort indicator
/// - Handles tap events for sorting interaction
///
/// ## Sort Indicator
///
/// The sort indicator visibility is controlled by configuration:
/// - Headers: `shouldShowHeaderSortingIndicator`
/// - Footers: `shouldShowFooterSortingIndicator`
///
/// ## Tap Handling
///
/// Header taps always trigger sorting (if column is sortable).
/// Footer taps only trigger sorting if `shouldFooterTriggerSorting` is `true`.
@MainActor
public class DataHeaderFooterViewModel: DataTableSortable {

    // MARK: - Properties

    /// The column title text to display.
    let data: String

    /// The index path of this column.
    var indexPath: IndexPath!

    /// Reference to the parent data table.
    var dataTable: SwiftDataTable!

    /// Whether this is a header or footer.
    var headerFooterType: HeaderFooterType = .header

    /// The current sort state for this column.
    public var sortType: DataTableSortType

    /// Whether the sorting indicator should be visible.
    ///
    /// Based on the header/footer type and corresponding configuration option.
    var shouldShowSortingIndicator: Bool {
        guard let options = dataTable?.options else { return true }
        switch headerFooterType {
        case .header:
            return options.shouldShowHeaderSortingIndicator
        case .footer:
            return options.shouldShowFooterSortingIndicator
        }
    }

    /// The image resource name for the current sort state.
    var imageStringForSortingElement: String? {
        guard shouldShowSortingIndicator else { return nil }
        switch self.sortType {
        case .hidden:
            return nil
        case .unspecified:
            return "column-sort-unspecified"
        case .ascending:
            return "column-sort-ascending"
        case .descending:
            return "column-sort-descending"
        }
    }

    /// The image to display for the current sort state.
    var imageForSortingElement: UIImage? {
        guard let imageName = self.imageStringForSortingElement else {
            return nil
        }
        let bundle = Bundle(for: DataHeaderFooter.self)
        guard
            let url = bundle.url(forResource: "SwiftDataTables", withExtension: "bundle"),
            let imageBundle = Bundle(url: url),
            let imagePath = imageBundle.path(forResource: imageName, ofType: "png"),
            let image = UIImage(contentsOfFile: imagePath)?.withRenderingMode(.alwaysTemplate)
        else {
            return nil
        }
        return image
    }

    /// The tint color for the sort indicator.
    ///
    /// Uses the configured `sortArrowTintColor` when actively sorted,
    /// gray when unspecified.
    var tintColorForSortingElement: UIColor? {
        return (dataTable != nil && sortType != .unspecified) ? dataTable.options.sortArrowTintColor : UIColor.gray
    }

    // MARK: - Lifecycle

    /// Creates a new header/footer view model.
    ///
    /// - Parameters:
    ///   - data: The column title text.
    ///   - sortType: The initial sort state.
    init(data: String, sortType: DataTableSortType) {
        self.data = data
        self.sortType = sortType
    }

    /// Configures the view model with its parent data table and position.
    ///
    /// - Parameters:
    ///   - dataTable: The parent SwiftDataTable.
    ///   - columnIndex: The zero-based column index.
    ///   - type: Whether this is a header or footer.
    public func configure(dataTable: SwiftDataTable, columnIndex: Int, type: HeaderFooterType = .header) {
        self.dataTable = dataTable
        self.indexPath = IndexPath(index: columnIndex)
        self.headerFooterType = type
    }
}

// MARK: - DataTableSupplementaryElementRepresentable

extension DataHeaderFooterViewModel: DataTableSupplementaryElementRepresentable {

    /// Registers the header/footer view class with the collection view.
    ///
    /// - Parameter collectionView: The collection view to register with.
    static func registerHeaderFooterViews(collectionView: UICollectionView) {
        let identifier = String(describing: DataHeaderFooter.self)
        let headerNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(headerNib, forCellWithReuseIdentifier: identifier)
    }

    /// Dequeues and configures a header/footer view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue from.
    ///   - kind: The supplementary view kind (header or footer).
    ///   - indexPath: The index path for the view.
    /// - Returns: A configured DataHeaderFooter view.
    func dequeueView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = String(describing: DataHeaderFooter.self)
        guard
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? DataHeaderFooter
        else {
            return UICollectionReusableView()
        }

        headerView.configure(viewModel: self)
        switch kind {
        case SwiftDataTable.SupplementaryViewType.columnHeader.rawValue:
            headerView.didTapEvent = { [weak self] in
                self?.headerViewDidTap()
            }
        case SwiftDataTable.SupplementaryViewType.footerHeader.rawValue:
            headerView.didTapEvent = { [weak self] in
                self?.footerViewDidTap()
            }
        default:
            break
        }
        return headerView
    }

    // MARK: - Events

    /// Handles header tap by triggering column sort.
    func headerViewDidTap() {
        self.dataTable.didTapColumn(index: self.indexPath)
    }

    /// Handles footer tap by notifying delegate and optionally triggering column sort.
    func footerViewDidTap() {
        self.dataTable.didTapFooter(index: self.indexPath)
    }
}
