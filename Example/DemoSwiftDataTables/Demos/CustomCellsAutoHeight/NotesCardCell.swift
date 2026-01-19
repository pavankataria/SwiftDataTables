//
//  NotesCardCell.swift
//  DemoSwiftDataTables
//
//  Custom cell displaying notes with an accent bar.
//

import UIKit

final class NotesCardCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let accentBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let notesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(accentBar)
        containerView.addSubview(notesLabel)

        let padding: CGFloat = 8

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            accentBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            accentBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            accentBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            accentBar.widthAnchor.constraint(equalToConstant: 4),

            notesLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            notesLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 8),
            notesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            notesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        ])
    }

    func configure(text: String) {
        notesLabel.text = text
    }
}
