//
//  RowHeightWrapDemoCell.swift
//  DemoSwiftDataTables
//
//  Custom cell used by RowHeightAndWrapDemoViewController.
//

import UIKit
import SwiftDataTables

final class RowHeightWrapDemoCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.backgroundColor = UIColor.secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        detailLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        detailLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(value: DataTableValueType, indexPath: IndexPath, wrap: Bool) {
        titleLabel.text = value.stringRepresentation
        titleLabel.numberOfLines = wrap ? 0 : 1
        titleLabel.lineBreakMode = wrap ? .byWordWrapping : .byTruncatingTail
        detailLabel.text = "Row \(indexPath.section + 1) · Col \(indexPath.item + 1)"
    }
}
