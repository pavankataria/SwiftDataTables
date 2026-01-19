//
//  RowHeightAndWrapDemoViewController.swift
//  SwiftDataTables
//
//  Demo for text wrapping + auto row heights with default and custom cells.
//

import UIKit
import SwiftDataTables

final class RowHeightAndWrapDemoViewController: UIViewController {

    private let headers = ["ID", "Name", "Notes"]
    private var rows: DataTableContent = []
    private var dataTable: SwiftDataTable?

    private lazy var rowCountControl: UISegmentedControl = {
        let control = UISegmentedControl(items: RowCountOption.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var widthStrategyControl: UISegmentedControl = {
        let control = UISegmentedControl(items: WidthStrategyOption.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var maxWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["None", "200", "280"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return control
    }()

    private lazy var wrapSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var autoHeightSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var customCellSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var scaleToFillSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(configChanged), for: .valueChanged)
        return toggle
    }()

    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var timingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.text = "—"
        return label
    }()

    private var controlsStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Row Height + Wrap Demo"
        view.backgroundColor = .systemBackground
        setupViews()
        rebuildTable()
    }

    private func setupViews() {
        let rowCountRow = labeledRow(label: "Rows", control: rowCountControl)
        let strategyRow = labeledRow(label: "Width strategy", control: widthStrategyControl)
        let maxWidthRow = labeledRow(label: "Max width", control: maxWidthControl)
        let wrapRow = labeledRow(label: "Wrap text", control: wrapSwitch)
        let heightRow = labeledRow(label: "Auto row height", control: autoHeightSwitch)
        let customRow = labeledRow(label: "Use custom cell", control: customCellSwitch)
        let scaleRow = labeledRow(label: "Scale columns to fill frame if shorter", control: scaleToFillSwitch)

        controlsStack = UIStackView(arrangedSubviews: [
            rowCountRow,
            strategyRow,
            maxWidthRow,
            wrapRow,
            heightRow,
            customRow,
            scaleRow,
            timingLabel,
            summaryLabel
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 8
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
        config.columnWidthMode = .fitContentText(strategy: selectedStrategy())
        config.minColumnWidth = 44
        config.maxColumnWidth = selectedMaxWidth()
        config.shouldContentWidthScaleToFillFrame = scaleToFillSwitch.isOn

        config.textLayout = wrapSwitch.isOn ? .wrap : .singleLine()
        config.rowHeightMode = autoHeightSwitch.isOn ? .automatic(estimated: 60) : .fixed(44)

        if customCellSwitch.isOn {
            config.cellSizingMode = .autoLayout(provider: makeCustomCellProvider())
            config.rowHeightMode = .automatic(estimated: 72)
        } else {
            config.cellSizingMode = .defaultCell
        }

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

        updateSummary(config: config, rowCount: rowCount)
    }

    private func updateSummary(config: DataTableConfiguration, rowCount: Int) {
        let strategy: String
        switch config.columnWidthMode {
        case .fixed(let width):
            strategy = "Fixed \(Int(width))"
        case .fitContentText(let textStrategy):
            switch textStrategy {
            case .estimatedAverage:
                strategy = "Estimated Avg"
            case .maxMeasured:
                strategy = "Max Measured"
            case .fixed(let width):
                strategy = "Fixed \(Int(width))"
            case .hybrid:
                strategy = "Hybrid"
            case .sampledMax:
                strategy = "Sampled Max"
            case .percentileMeasured:
                strategy = "Percentile"
            }
        case .fitContentAutoLayout:
            strategy = "AutoLayout"
        }

        let wrap = wrapSwitch.isOn ? "wrap ON" : "wrap OFF"
        let rowHeight = autoHeightSwitch.isOn ? "auto height" : "fixed 44"
        let custom = customCellSwitch.isOn ? "custom cell" : "default cell"
        let maxWidth = selectedMaxWidth().map { "max \($0)" } ?? "max none"
        let scale = scaleToFillSwitch.isOn ? "scale-to-fill ON" : "scale-to-fill OFF"

        summaryLabel.text = [
            "\(rowCount) rows · \(strategy)",
            "\(wrap) · \(rowHeight) · \(custom)",
            "\(maxWidth) · \(scale)"
        ].joined(separator: "\n")
    }

    private func selectedRowCount() -> Int {
        let option = RowCountOption(rawValue: rowCountControl.selectedSegmentIndex) ?? .small
        return option.value
    }

    private func selectedStrategy() -> DataTableColumnWidthStrategy {
        let option = WidthStrategyOption(rawValue: widthStrategyControl.selectedSegmentIndex) ?? .estimatedAverage
        return option.strategy
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
            "Alex", "Bianca", "Christopher Alexander", "Diana", "Elliot", "Fatima", "Giancarlo"
        ]
        let notes = [
            "Short",
            "A longer note that should wrap on narrow columns.",
            "This is a very long note meant to stress wrapping and row height measurement for the demo.",
            "Medium length note with some extra words.",
            "Another long description that keeps going to test auto layout sizing."
        ]

        for i in 0..<count {
            let name = names[i % names.count]
            let note = notes[i % notes.count]
            data.append([
                .int(i + 1),
                .string(name),
                .string(note)
            ])
        }
        return data
    }

    private func makeCustomCellProvider() -> DataTableCustomCellProvider {
        let reuseIdentifier = String(describing: RowHeightWrapDemoCell.self)
        let wrap = wrapSwitch.isOn

        return DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(RowHeightWrapDemoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            reuseIdentifierFor: { _ in reuseIdentifier },
            configure: { cell, value, indexPath in
                guard let cell = cell as? RowHeightWrapDemoCell else { return }
                cell.configure(value: value, indexPath: indexPath, wrap: wrap)
            },
            sizingCellFor: { _ in RowHeightWrapDemoCell() }
        )
    }
}
