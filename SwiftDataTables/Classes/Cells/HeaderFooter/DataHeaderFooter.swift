//
//  DataHeaderFooter.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Reusable view for column headers and footers in a SwiftDataTable.
///
/// `DataHeaderFooter` displays a column title with an optional sorting indicator.
/// It's used for both the top header row and bottom footer row, with the sorting
/// indicator visibility controlled by configuration.
///
/// ## Layout
///
/// The view contains:
/// - A title label (left-aligned, bold system font)
/// - A sorting indicator image view (right-aligned, when visible)
///
/// When the sorting indicator is hidden, the title label expands to fill
/// the available width.
///
/// ## Interaction
///
/// Tapping the view triggers `didTapEvent`, which the data table uses to
/// cycle the sort order for that column.
///
/// ## Sorting Indicator
///
/// The indicator shows one of three states:
/// - Unspecified: Both arrows (neutral)
/// - Ascending: Up arrow
/// - Descending: Down arrow
/// - Hidden: No indicator (for non-sortable columns)
class DataHeaderFooter: UICollectionReusableView {

    // MARK: - Properties

    /// Layout constants for the header/footer view.
    enum Properties {

        /// Horizontal margin for the title label.
        static let labelHorizontalMargin: CGFloat = 15

        /// Vertical margin for the title label.
        static let labelVerticalMargin: CGFloat = 5

        /// Spacing between label and sorting indicator.
        static let separator: CGFloat = 5

        /// Horizontal margin for the sorting image view.
        static let imageViewHorizontalMargin: CGFloat = 5

        /// Minimum width for the title label.
        static let labelWidthConstant: CGFloat = 20

        /// Width of the sorting indicator image.
        static let imageViewWidthConstant: CGFloat = 20

        /// Aspect ratio (width/height) of the sorting indicator.
        static let imageViewAspectRatio: CGFloat = 0.75

        /// Total width occupied by the sort indicator area.
        static var sortIndicatorWidth: CGFloat {
            separator + imageViewWidthConstant + imageViewHorizontalMargin
        }
    }

    /// The label displaying the column title.
    let titleLabel = UILabel()

    /// The image view displaying the sort direction indicator.
    let sortingImageView = UIImageView()

    /// Constraint: label trailing to sorting image leading.
    private var labelTrailingToImageConstraint: NSLayoutConstraint?

    /// Constraint: label trailing to superview (when indicator hidden).
    private var labelTrailingToSuperviewConstraint: NSLayoutConstraint?

    /// Constraints for the sorting image view.
    private var sortingImageConstraints: [NSLayoutConstraint] = []

    // MARK: - Events

    /// Closure called when the view is tapped.
    var didTapEvent: (() -> Void)? = nil

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .heavy)
        addSubview(titleLabel)
        addSubview(sortingImageView)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(DataHeaderFooter.didTapView))
        addGestureRecognizer(tapGesture)
    }

    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortingImageView.translatesAutoresizingMaskIntoConstraints = false

        // Base label constraints (always active)
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Properties.labelWidthConstant),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Properties.labelVerticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Properties.labelHorizontalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Properties.labelVerticalMargin),
        ])

        // Sorting image constraints (activated only when indicator is visible)
        sortingImageConstraints = [
            sortingImageView.widthAnchor.constraint(equalToConstant: Properties.imageViewWidthConstant),
            sortingImageView.widthAnchor.constraint(equalTo: sortingImageView.heightAnchor, multiplier: Properties.imageViewAspectRatio),
            sortingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sortingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Properties.imageViewHorizontalMargin),
        ]

        // Label trailing constraint when sorting indicator is visible
        labelTrailingToImageConstraint = sortingImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Properties.separator)

        // Label trailing constraint when sorting indicator is hidden (full width)
        labelTrailingToSuperviewConstraint = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Properties.labelHorizontalMargin)

        // Default: show sorting indicator
        NSLayoutConstraint.activate(sortingImageConstraints)
        labelTrailingToImageConstraint?.isActive = true
    }

    // MARK: - Layout Updates

    private func updateLayoutForSortingIndicator(visible: Bool) {
        if visible {
            sortingImageView.isHidden = false
            labelTrailingToSuperviewConstraint?.isActive = false
            NSLayoutConstraint.activate(sortingImageConstraints)
            labelTrailingToImageConstraint?.isActive = true
        } else {
            sortingImageView.isHidden = true
            labelTrailingToImageConstraint?.isActive = false
            NSLayoutConstraint.deactivate(sortingImageConstraints)
            labelTrailingToSuperviewConstraint?.isActive = true
        }
    }

    // MARK: - Configuration

    /// Configures the view with a view model.
    ///
    /// - Parameter viewModel: The view model containing title and sort state.
    func configure(viewModel: DataHeaderFooterViewModel) {
        self.titleLabel.text = viewModel.data
        self.sortingImageView.image = viewModel.imageForSortingElement
        self.sortingImageView.tintColor = viewModel.tintColorForSortingElement
        self.backgroundColor = .systemBackground
        updateLayoutForSortingIndicator(visible: viewModel.shouldShowSortingIndicator)
    }

    // MARK: - Actions

    @objc func didTapView() {
        self.didTapEvent?()
    }
}
