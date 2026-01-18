//
//  ColumnWidthStrategyDemoViewController.swift
//  SwiftDataTables
//
//  Shows how different column width strategies behave on the same dataset.
//

import UIKit
import SwiftDataTables

final class ColumnWidthStrategyDemoViewController: UIViewController {

    private struct StrategyOption {
        let title: String
        let description: String
        let strategy: DataTableColumnWidthStrategy
    }

    private lazy var strategyOptions: [StrategyOption] = [
        StrategyOption(
            title: "Default: Estimated",
            description: "Default. Fast; uses char count × 7pt (averageCharWidth).",
            strategy: .estimated(averageCharWidth: 7)
        ),
        StrategyOption(
            title: "Hybrid",
            description: "Estimated avg + measured sampled max (12 rows).",
            strategy: .hybrid(sampleSize: 12, averageCharWidth: 7)
        ),
        StrategyOption(
            title: "Sampled Max",
            description: "Deterministic sample (12 rows), take max width.",
            strategy: .sampledMax(sampleSize: 12)
        ),
        StrategyOption(
            title: "95th %ile",
            description: "Deterministic sample (12 rows), take 95th percentile.",
            strategy: .percentileMeasured(percentile: 0.95, sampleSize: 12)
        ),
        StrategyOption(
            title: "Max Measured",
            description: "Measure every row; most accurate, slowest.",
            strategy: .maxMeasured
        ),
        StrategyOption(
            title: "Fixed 140",
            description: "Fixed width before clamping/padding.",
            strategy: .fixed(width: 140)
        ),
    ]

    private var selectedIndex = 0 // Estimated is the library default

    private lazy var strategyButtons: [UIButton] = {
        return strategyOptions.enumerated().map { index, option in
            let button = UIButton(type: .system)
            button.setTitle(option.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.8
            button.tag = index
            button.addTarget(self, action: #selector(strategyButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
            return button
        }
    }()

    private lazy var buttonGridStack: UIStackView = {
        // Row 1: first 3 buttons
        let row1 = UIStackView(arrangedSubviews: Array(strategyButtons[0..<3]))
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        // Row 2: last 3 buttons
        let row2 = UIStackView(arrangedSubviews: Array(strategyButtons[3..<6]))
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [row1, row2])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var strategyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var minWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["44", "70", "90"])
        control.selectedSegmentIndex = 0 // 44 keeps the ID column tighter
        control.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var maxWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["None", "200", "280"])
        control.selectedSegmentIndex = 0 // No clamp by default
        control.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var providerSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private lazy var providerIDWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["60", "80", "100"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        return control
    }()

    private lazy var providerNameWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["120", "140", "180"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        return control
    }()

    private lazy var providerNotesWidthControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["220", "280", "340"])
        control.selectedSegmentIndex = 1
        control.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        return control
    }()

    private lazy var scaleToFillSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(configOptionChanged), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private lazy var configSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?

    private let headers = ["ID", "Name", "Notes"]
    private lazy var rows: DataTableContent = makeRows()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Column Width Strategies"
        view.backgroundColor = .systemBackground
        setupViews()
        updateButtonAppearance()
        applyStrategy(index: selectedIndex)
    }

    private func setupViews() {
        let minRow = labeledRow(label: "Min width", control: minWidthControl)
        let maxRow = labeledRow(label: "Max width", control: maxWidthControl)
        let providerRow = labeledRow(label: "Use columnWidthProvider", control: providerSwitch)
        let providerIDRow = labeledRow(label: "Provider: ID width", control: providerIDWidthControl)
        let providerNameRow = labeledRow(label: "Provider: Name width", control: providerNameWidthControl)
        let providerNotesRow = labeledRow(label: "Provider: Notes width", control: providerNotesWidthControl)
        let scaleRow = labeledRow(label: "Scale to fill frame", control: scaleToFillSwitch)

        controlsStack = UIStackView(arrangedSubviews: [
            buttonGridStack,
            strategyDescriptionLabel,
            minRow,
            maxRow,
            providerRow,
            providerIDRow,
            providerNameRow,
            providerNotesRow,
            scaleRow,
            configSummaryLabel
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
        updateProviderControlsEnabled()
    }

    private func updateButtonAppearance() {
        for (index, button) in strategyButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.backgroundColor = isSelected ? .systemBlue : .clear
            button.setTitleColor(isSelected ? .white : .systemBlue, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    @objc private func strategyButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateButtonAppearance()
        applyStrategy(index: selectedIndex)
    }

    private func applyStrategy(index: Int) {
        guard strategyOptions.indices.contains(index) else { return }
        let option = strategyOptions[index]
        strategyDescriptionLabel.text = option.description

        var config = DataTableConfiguration()
        config.columnWidthStrategy = option.strategy
        config.minColumnWidth = currentMinWidth()
        config.maxColumnWidth = currentMaxWidth()
        config.shouldContentWidthScaleToFillFrame = scaleToFillSwitch.isOn

        if providerSwitch.isOn {
            // Provider overrides strategy; keep it simple to demonstrate the API.
            config.columnWidthProvider = { index, _, _, _ in
                switch index {
                case 0: return self.currentProviderIDWidth()
                case 1: return self.currentProviderNameWidth()
                case 2: return self.currentProviderNotesWidth()
                default: return self.currentProviderNameWidth()
                }
            }
        }

        rebuildTable(with: config)
        updateConfigSummary(config)
    }

    private func rebuildTable(with configuration: DataTableConfiguration) {
        dataTable?.removeFromSuperview()

        let table = SwiftDataTable(data: rows, headerTitles: headers, options: configuration)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
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

    private func currentMinWidth() -> CGFloat {
        switch minWidthControl.selectedSegmentIndex {
        case 0: return 44
        case 2: return 90
        default: return 70
        }
    }

    private func currentMaxWidth() -> CGFloat? {
        switch maxWidthControl.selectedSegmentIndex {
        case 1: return 200
        case 2: return 280
        default: return nil
        }
    }

    private func updateConfigSummary(_ config: DataTableConfiguration) {
        let option = strategyOptions[selectedIndex]
        let strategyInfo: String
        switch option.strategy {
        case .percentileMeasured(let p, let n):
            strategyInfo = "\(option.title): \(Int(p * 100))th percentile over \(n) sampled rows."
        case .hybrid(let n, let w):
            strategyInfo = "\(option.title): estimated (w=\(Int(w))pt) + sampled max over \(n) rows."
        case .sampledMax(let n):
            strategyInfo = "\(option.title): sampled max over \(n) rows."
        case .estimated(let w):
            strategyInfo = "\(option.title): estimated via char count × \(Int(w))pt."
        case .fixed(let w):
            strategyInfo = "\(option.title): fixed \(Int(w))pt before padding/clamp."
        case .maxMeasured:
            strategyInfo = "\(option.title): max of all measured rows."
        }

        let min = "min \(Int(config.minColumnWidth))pt"
        let max = config.maxColumnWidth.map { "max \(Int($0))pt (soft cap)" } ?? "max none"
        let provider: String
        if providerSwitch.isOn {
            provider = "provider ON (ID→\(Int(currentProviderIDWidth())) • Name→\(Int(currentProviderNameWidth())) • Notes→\(Int(currentProviderNotesWidth())); padded/clamped)"
        } else {
            provider = "provider OFF"
        }
        let scaleNote = scaleToFillSwitch.isOn ? "scale-to-fill ON (columns are proportionally expanded)" : "scale-to-fill OFF"
        let headerNote = "Note: header minimum can exceed max; header wins."

        configSummaryLabel.text = [
            strategyInfo,
            "\(min) · \(max)",
            provider,
            scaleNote,
            headerNote
        ].joined(separator: "\n")
    }

    @objc private func configOptionChanged() {
        updateProviderControlsEnabled()
        applyStrategy(index: selectedIndex)
    }

    private func updateProviderControlsEnabled() {
        let isEnabled = providerSwitch.isOn
        providerIDWidthControl.isEnabled = isEnabled
        providerNameWidthControl.isEnabled = isEnabled
        providerNotesWidthControl.isEnabled = isEnabled
    }

    private func currentProviderIDWidth() -> CGFloat {
        switch providerIDWidthControl.selectedSegmentIndex {
        case 1: return 80
        case 2: return 100
        default: return 60
        }
    }

    private func currentProviderNameWidth() -> CGFloat {
        switch providerNameWidthControl.selectedSegmentIndex {
        case 0: return 80
        case 2: return 140
        default: return 100
        }
    }

    private func currentProviderNotesWidth() -> CGFloat {
        switch providerNotesWidthControl.selectedSegmentIndex {
        case 0: return 220
        case 2: return 340
        default: return 280
        }
    }

    private func makeRows() -> DataTableContent {
        let longNote = "This is a very long note that simulates an outlier and should force wide columns when using max widths."
        let mediumNote = "Medium length note that is common."
        let shortNote = "Short"

        var content: DataTableContent = [
            [.int(1), .string("Alice"), .string(shortNote)],
            [.int(2), .string("Bob"), .string(shortNote)],
            [.int(3), .string("Charlie"), .string(mediumNote)],
            [.int(4), .string("Diana"), .string(shortNote)],
            [.int(5), .string("Eve"), .string(shortNote)],
            [.int(6), .string("Frank"), .string(mediumNote)],
            [.int(7), .string("Grace"), .string(shortNote)],
            [.int(8), .string("Henry"), .string(shortNote)],
            [.int(9), .string("Ivy"), .string(shortNote)],
            [.int(10), .string("Jack"), .string(shortNote)],
            [.int(11), .string("Kara"), .string(mediumNote)],
            [.int(12), .string("Liam"), .string(shortNote)],
            [.int(13), .string("Mona"), .string(shortNote)],
            [.int(14), .string("Nina"), .string(shortNote)],
            [.int(15), .string("Omar"), .string(shortNote)],
            [.int(16), .string("Pete"), .string(shortNote)],
            [.int(17), .string("Quinn"), .string(shortNote)],
            [.int(18), .string("Ruth"), .string(shortNote)],
            [.int(19), .string("Sara"), .string(shortNote)],
            [.int(20), .string("Tara"), .string(shortNote)],
        ]

        // Insert an outlier near the end so sampling differences are visible.
        content.insert([.int(21), .string("Uma"), .string(longNote)], at: 15)
        return content
    }
}
