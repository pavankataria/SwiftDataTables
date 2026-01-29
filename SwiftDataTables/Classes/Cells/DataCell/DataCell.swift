//
//  DataCell.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// The default cell used to display data values in a SwiftDataTable.
///
/// `DataCell` is a simple text-based cell that displays a single `DataTableValueType`
/// value. It supports both single-line truncation and multi-line wrapping layouts.
///
/// ## Layout
///
/// The cell contains a single `UILabel` with configurable margins:
/// - Vertical margin: 5 points top/bottom
/// - Horizontal margin: 15 points leading/trailing
/// - Minimum width: 20 points
///
/// ## Text Layout Modes
///
/// Configure via `DataTableConfiguration.textLayout`:
/// - `.singleLine(truncation:)`: Single line with specified truncation mode
/// - `.wrap`: Multi-line with word wrapping
///
/// ## Custom Cells
///
/// For custom cell types, use `DataTableCustomCellProvider` with
/// `DataTableCellSizingMode.autoLayout` instead of subclassing this cell.
///
/// ## Customizing Default Cells
///
/// To customize the appearance of default cells without creating a custom cell class,
/// use ``DataTableConfiguration/defaultCellConfiguration``:
///
/// ```swift
/// var config = DataTableConfiguration()
/// config.defaultCellConfiguration = { cell, value, indexPath, isHighlighted in
///     cell.dataLabel.font = UIFont(name: "Avenir", size: 14)
///     cell.dataLabel.textColor = .darkGray
/// }
/// ```
public class DataCell: UICollectionViewCell {

    // MARK: - Properties

    /// Layout constants for cell padding and sizing.
    public enum Properties {

        /// Vertical padding between label and cell edges.
        public static let verticalMargin: CGFloat = 5

        /// Horizontal padding between label and cell edges.
        public static let horizontalMargin: CGFloat = 15

        /// Minimum width constraint for the label.
        public static let widthConstant: CGFloat = 20

        /// Default font used for cell text.
        public static let defaultFont: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    }

    /// The label displaying the cell's text content.
    ///
    /// Access this property in ``DataTableConfiguration/defaultCellConfiguration``
    /// to customize font, text color, alignment, and other label properties.
    public let dataLabel = UILabel()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        // Reset label properties to defaults so cell reuse doesn't retain old styling
        dataLabel.font = Properties.defaultFont
        dataLabel.textColor = .label
        dataLabel.textAlignment = .natural
        backgroundColor = nil
        contentView.backgroundColor = nil
    }

    // MARK: - Setup

    private func setup() {
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = Properties.defaultFont
        contentView.addSubview(dataLabel)
        NSLayoutConstraint.activate([
            dataLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Properties.widthConstant),
            dataLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Properties.verticalMargin),
            dataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Properties.verticalMargin),
            dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Properties.horizontalMargin),
            dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Properties.horizontalMargin),
        ])
    }

    // MARK: - Configuration

    /// Configures the cell with a view model.
    ///
    /// - Parameter viewModel: The view model containing the data to display.
    func configure(_ viewModel: DataCellViewModel) {
        self.dataLabel.text = viewModel.data.stringRepresentation
    }

    /// Applies the specified text layout mode to the cell.
    ///
    /// - Parameter layout: The text layout mode to apply.
    func applyTextLayout(_ layout: DataTableTextLayout) {
        switch layout {
        case .singleLine(let truncation):
            dataLabel.numberOfLines = 1
            dataLabel.lineBreakMode = truncation
        case .wrap:
            dataLabel.numberOfLines = 0
            dataLabel.lineBreakMode = .byWordWrapping
        }
    }
}
