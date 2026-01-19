//
//  CustomCellsAutoHeightDemoViewController.swift
//  SwiftDataTables
//
//  Demo for custom cells with Auto Layout sizing (height only).
//

import UIKit
import SwiftDataTables

final class CustomCellsAutoHeightDemoViewController: UIViewController {

    private enum WidthModeOption: Int, CaseIterable {
        case textEstimated
        case textMax
        case fixed

        var title: String {
            switch self {
            case .textEstimated: return "Text Est"
            case .textMax: return "Text Max"
            case .fixed: return "Fixed 140"
            }
        }

        var mode: DataTableColumnWidthMode {
            switch self {
            case .textEstimated:
                return .fitContentText(strategy: .estimatedAverage(averageCharWidth: 7))
            case .textMax:
                return .fitContentText(strategy: .maxMeasured)
            case .fixed:
                return .fixed(width: 140)
            }
        }
    }

    private enum RowCountOption: Int, CaseIterable {
        case small
        case medium
        case large

        var title: String {
            switch self {
            case .small: return "50"
            case .medium: return "200"
            case .large: return "1k"
            }
        }

        var value: Int {
            switch self {
            case .small: return 50
            case .medium: return 200
            case .large: return 1000
            }
        }
    }

    private let headers = ["#", "User", "Status", "Notes"]
    private var rows: DataTableContent = []
    private var dataTable: SwiftDataTable?

    private lazy var rowCountControl: UISegmentedControl = {
        let control = UISegmentedControl(items: RowCountOption.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var widthModeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: WidthModeOption.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var maxWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["None", "200", "280"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var scaleToFillSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Custom cells with Auto Layout. Each column uses a different cell type. Row heights are computed via systemLayoutSizeFitting."
        return label
    }()

    private lazy var timingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.text = "—"
        return label
    }()

    private var controlsStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Cells + Auto Height"
        view.backgroundColor = .systemBackground
        setupViews()
        rebuildTable()
    }

    private func setupViews() {
        let rowCountRow = labeledRow(label: "Rows", control: rowCountControl)
        let widthRow = labeledRow(label: "Width mode", control: widthModeControl)
        let maxWidthRow = labeledRow(label: "Max width", control: maxWidthControl)
        let scaleRow = labeledRow(label: "Scale to fill", control: scaleToFillSwitch)

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            timingLabel,
            rowCountRow,
            widthRow,
            maxWidthRow,
            scaleRow
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 10
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    @objc private func configChanged() {
        rebuildTable()
    }

    private func rebuildTable() {
        let rowCount = selectedRowCount()
        rows = makeRows(count: rowCount)

        var config = DataTableConfiguration()
        config.columnWidthMode = selectedWidthMode()
        config.minColumnWidth = 50
        config.maxColumnWidth = selectedMaxWidth()
        config.shouldContentWidthScaleToFillFrame = scaleToFillSwitch.isOn
        config.shouldShowSearchSection = false
        config.textLayout = .singleLine()
        config.cellSizingMode = .autoLayout(provider: makeCustomCellProvider())
        config.rowHeightMode = .automatic(estimated: 60)

        dataTable?.removeFromSuperview()
        let start = Date()
        let table = SwiftDataTable(data: rows, headerTitles: headers, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
        view.layoutIfNeeded()
        let elapsed = Date().timeIntervalSince(start)
        timingLabel.text = String(format: "%.3fs", elapsed)
    }

    private func selectedRowCount() -> Int {
        let option = RowCountOption(rawValue: rowCountControl.selectedSegmentIndex) ?? .small
        return option.value
    }

    private func selectedWidthMode() -> DataTableColumnWidthMode {
        let option = WidthModeOption(rawValue: widthModeControl.selectedSegmentIndex) ?? .textEstimated
        return option.mode
    }

    private func selectedMaxWidth() -> CGFloat? {
        switch maxWidthControl.selectedSegmentIndex {
        case 1: return 200
        case 2: return 280
        default: return nil
        }
    }

    private func labeledRow(label: String, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.text = label

        let row = UIStackView(arrangedSubviews: [titleLabel, control])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    private func makeRows(count: Int) -> DataTableContent {
        var data = DataTableContent()
        let names = [
            "Alex Johnson", "Bianca Lee", "Chris Alexander", "Diana Patel",
            "Elliot Rivera", "Fatima Khan", "Giancarlo Rossi", "Hannah Kim"
        ]
        let statuses = ["Active", "Pending", "Inactive", "VIP"]
        let notes = [
            "Short note",
            "Medium-length note with more details here",
            "This is a longer note that spans multiple lines and demonstrates how the cell expands vertically to fit content",
            "• Item one\n• Item two\n• Item three",
            "Contact prefers email. Follow up next week regarding the proposal."
        ]

        for i in 0..<count {
            let name = names[i % names.count]
            let status = statuses[i % statuses.count]
            let note = notes[i % notes.count]
            data.append([
                .int(i + 1),
                .string(name),
                .string(status),
                .string(note)
            ])
        }
        return data
    }

    private func makeCustomCellProvider() -> DataTableCustomCellProvider {
        let indexReuse = "IndexCell"
        let userReuse = "UserCell"
        let statusReuse = "StatusCell"
        let notesReuse = "NotesCell"

        return DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(IndexBadgeCell.self, forCellWithReuseIdentifier: indexReuse)
                collectionView.register(UserCardCell.self, forCellWithReuseIdentifier: userReuse)
                collectionView.register(StatusPillCell.self, forCellWithReuseIdentifier: statusReuse)
                collectionView.register(NotesCardCell.self, forCellWithReuseIdentifier: notesReuse)
            },
            reuseIdentifierFor: { indexPath in
                switch indexPath.item {
                case 0: return indexReuse
                case 1: return userReuse
                case 2: return statusReuse
                default: return notesReuse
                }
            },
            configure: { cell, value, indexPath in
                switch indexPath.item {
                case 0:
                    (cell as? IndexBadgeCell)?.configure(with: value.stringRepresentation)
                case 1:
                    (cell as? UserCardCell)?.configure(name: value.stringRepresentation, row: indexPath.section)
                case 2:
                    (cell as? StatusPillCell)?.configure(status: value.stringRepresentation)
                default:
                    (cell as? NotesCardCell)?.configure(text: value.stringRepresentation)
                }
            },
            sizingCellFor: { reuseId in
                switch reuseId {
                case indexReuse: return IndexBadgeCell()
                case userReuse: return UserCardCell()
                case statusReuse: return StatusPillCell()
                default: return NotesCardCell()
                }
            }
        )
    }
}

// MARK: - Custom Cell: Index Badge

final class IndexBadgeCell: UICollectionViewCell {
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
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
        contentView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),
            badgeLabel.heightAnchor.constraint(equalToConstant: 28),
            badgeLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            badgeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    func configure(with text: String) {
        badgeLabel.text = text
    }
}

// MARK: - Custom Cell: User Card

final class UserCardCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
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
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(subtitleLabel)

        let padding: CGFloat = 8

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 24),
            avatarImageView.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),

            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        ])
    }

    func configure(name: String, row: Int) {
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        nameLabel.text = name
        subtitleLabel.text = row % 2 == 0 ? "Premium Member" : "Standard"
    }
}

// MARK: - Custom Cell: Status Pill

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

// MARK: - Custom Cell: Notes Card

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
