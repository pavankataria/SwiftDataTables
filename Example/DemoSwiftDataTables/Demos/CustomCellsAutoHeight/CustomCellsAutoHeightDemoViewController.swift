//
//  CustomCellsAutoHeightDemoViewController.swift
//  SwiftDataTables
//
//  Demo for custom cells with Auto Layout sizing (height only).
//

import UIKit
import SwiftDataTables

final class CustomCellsAutoHeightDemoViewController: UIViewController {

    private let headers = ["#", "User", "Status", "Notes"]
    private var rows: DataTableContent = []
    private var dataTable: SwiftDataTable?

    private lazy var rowCountControl: UISegmentedControl = {
        let control = UISegmentedControl(items: CustomCellsRowCountOption.allCases.map { $0.title })
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
        let option = CustomCellsRowCountOption(rawValue: rowCountControl.selectedSegmentIndex) ?? .small
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
