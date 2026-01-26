//
//  DataHeaderFooter.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2017 Pavan Kataria. All rights reserved.
//

import UIKit

class DataHeaderFooter: UICollectionReusableView {

    //MARK: - Properties
    enum Properties {
        static let labelHorizontalMargin: CGFloat = 15
        static let labelVerticalMargin: CGFloat = 5
        static let separator: CGFloat = 5
        static let imageViewHorizontalMargin: CGFloat = 5
        static let labelWidthConstant: CGFloat = 20
        static let imageViewWidthConstant: CGFloat = 20
        static let imageViewAspectRatio: CGFloat = 0.75

        static var sortIndicatorWidth: CGFloat {
            separator + imageViewWidthConstant + imageViewHorizontalMargin
        }
    }
    let titleLabel = UILabel()
    let sortingImageView = UIImageView()

    // Constraints for dynamic layout based on sorting indicator visibility
    private var labelTrailingToImageConstraint: NSLayoutConstraint?
    private var labelTrailingToSuperviewConstraint: NSLayoutConstraint?
    private var sortingImageConstraints: [NSLayoutConstraint] = []


    //MARK: - Events
    var didTapEvent: (() -> Void)? = nil

    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
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
    
    func configure(viewModel: DataHeaderFooterViewModel) {
        self.titleLabel.text = viewModel.data
        self.sortingImageView.image = viewModel.imageForSortingElement
        self.sortingImageView.tintColor = viewModel.tintColorForSortingElement
        self.backgroundColor = .systemBackground
        updateLayoutForSortingIndicator(visible: viewModel.shouldShowSortingIndicator)
    }
    @objc func didTapView(){
        self.didTapEvent?()
    }
}
