//
//  PaginationHeader.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 03/03/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit

/// Reusable view for pagination controls (placeholder).
///
/// `PaginationHeader` is a placeholder view for future pagination functionality.
/// Currently displays a simple "Pagination" label.
///
/// ## Future Enhancement
///
/// This view will eventually contain:
/// - Page number display
/// - Previous/Next buttons
/// - Page size selector
/// - Jump to page controls
///
/// ## Layout
///
/// The label fills the entire view with edge-to-edge constraints.
class PaginationHeader: UICollectionReusableView {

    // MARK: - Properties

    /// The label displaying pagination text.
    let label = UILabel()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.text = "Pagination"
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Configuration

    /// Configures the view with a view model.
    ///
    /// - Parameter viewModel: The view model (currently unused).
    func configure(_ viewModel: PaginationHeaderViewModel) {
    }
}
