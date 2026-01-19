//
//  FixedColumnsDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for fixed (frozen) columns.
//  Adjust left and right frozen column counts in real-time.
//

import UIKit
import SwiftDataTables

final class FixedColumnsDemoViewController: UIViewController {

    // MARK: - Properties

    private var leftColumnsCount: Int = 1
    private var rightColumnsCount: Int = 1
    private let maxColumns = 6

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Fixed (frozen) columns stay visible while scrolling horizontally. Adjust the number of frozen columns on each side and scroll to see the effect."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var leftColumnsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = Double(maxColumns - 1)
        stepper.value = Double(leftColumnsCount)
        stepper.addTarget(self, action: #selector(leftStepperChanged), for: .valueChanged)
        return stepper
    }()

    private lazy var leftColumnsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }()

    private lazy var rightColumnsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = Double(maxColumns - 1)
        stepper.value = Double(rightColumnsCount)
        stepper.addTarget(self, action: #selector(rightStepperChanged), for: .valueChanged)
        return stepper
    }()

    private lazy var rightColumnsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }()

    private lazy var configSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable?

    private let headers = ["ID", "Name", "Email", "Number", "City", "Balance"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fixed Columns"
        view.backgroundColor = .systemBackground
        setupViews()
        updateUI()
        rebuildTable()
    }

    // MARK: - Setup

    private func setupViews() {
        let leftRow = labeledRow(
            label: "Frozen left columns",
            valueLabel: leftColumnsLabel,
            stepper: leftColumnsStepper
        )

        let rightRow = labeledRow(
            label: "Frozen right columns",
            valueLabel: rightColumnsLabel,
            stepper: rightColumnsStepper
        )

        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            leftRow,
            rightRow,
            configSummaryLabel
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func labeledRow(label: String, valueLabel: UILabel, stepper: UIStepper) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.text = label

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, valueLabel, stepper])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    // MARK: - Actions

    @objc private func leftStepperChanged() {
        let newValue = Int(leftColumnsStepper.value)
        // Ensure total frozen columns don't exceed available columns
        if newValue + rightColumnsCount >= maxColumns {
            rightColumnsCount = max(0, maxColumns - newValue - 1)
            rightColumnsStepper.value = Double(rightColumnsCount)
        }
        leftColumnsCount = newValue
        updateUI()
        rebuildTable()
    }

    @objc private func rightStepperChanged() {
        let newValue = Int(rightColumnsStepper.value)
        // Ensure total frozen columns don't exceed available columns
        if leftColumnsCount + newValue >= maxColumns {
            leftColumnsCount = max(0, maxColumns - newValue - 1)
            leftColumnsStepper.value = Double(leftColumnsCount)
        }
        rightColumnsCount = newValue
        updateUI()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateUI() {
        leftColumnsLabel.text = "\(leftColumnsCount)"
        rightColumnsLabel.text = "\(rightColumnsCount)"

        var summaryParts: [String] = []

        if leftColumnsCount > 0 {
            let leftNames = headers.prefix(leftColumnsCount).joined(separator: ", ")
            summaryParts.append("Left frozen: \(leftNames)")
        }

        if rightColumnsCount > 0 {
            let rightNames = headers.suffix(rightColumnsCount).joined(separator: ", ")
            summaryParts.append("Right frozen: \(rightNames)")
        }

        if summaryParts.isEmpty {
            configSummaryLabel.text = "No frozen columns. All columns scroll freely."
        } else {
            let scrollableCount = maxColumns - leftColumnsCount - rightColumnsCount
            summaryParts.append("Scrollable columns: \(scrollableCount)")
            configSummaryLabel.text = summaryParts.joined(separator: "\n")
        }
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        if leftColumnsCount > 0 || rightColumnsCount > 0 {
            config.fixedColumns = DataTableFixedColumnType(
                leftColumns: leftColumnsCount,
                rightColumns: rightColumnsCount
            )
        }

        let table = SwiftDataTable(
            data: makeData(),
            headerTitles: headers,
            options: config
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
    }

    // MARK: - Data

    private func makeData() -> DataTableContent {
        return exampleDataSet().map { row in
            row.compactMap { DataTableValueType($0) }
        }
    }
}
