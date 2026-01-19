//
//  StatusPillCell.swift
//  DemoSwiftDataTables
//
//  Custom cell displaying a coloured status pill.
//

import UIKit

final class StatusPillCell: UICollectionViewCell {
    private let pillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
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
        contentView.addSubview(pillView)
        pillView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            pillView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pillView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pillView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            pillView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),

            statusLabel.topAnchor.constraint(equalTo: pillView.topAnchor, constant: 6),
            statusLabel.bottomAnchor.constraint(equalTo: pillView.bottomAnchor, constant: -6),
            statusLabel.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -12),
        ])
    }

    func configure(status: String) {
        statusLabel.text = status

        switch status.lowercased() {
        case "active":
            pillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusLabel.textColor = .systemGreen
        case "pending":
            pillView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            statusLabel.textColor = .systemOrange
        case "inactive":
            pillView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
            statusLabel.textColor = .systemGray
        case "vip":
            pillView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
            statusLabel.textColor = .systemPurple
        default:
            pillView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            statusLabel.textColor = .systemBlue
        }
    }
}
