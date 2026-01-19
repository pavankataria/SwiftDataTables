//
//  PerformanceDemoViewController.swift
//  SwiftDataTables_Example
//
//  Created by Pavan Kataria on 2025.
//  Copyright © 2025 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class PerformanceDemoViewController: UIViewController {

    private let rowCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1000
        stepper.maximumValue = 100000
        stepper.stepValue = 10000
        stepper.value = 50000
        return stepper
    }()

    private let rowCountLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "This demo showcases SwiftDataTables rendering large datasets. Adjust the row count and tap Reload to measure render time."
        return label
    }()

    private let timingLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.text = "—"
        return label
    }()

    private let reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reload Table", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    private var controlsStack: UIStackView!
    private var dataTable: SwiftDataTable!
    private var currentRowCount: Int = 50000

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Performance Stress Test"
        view.backgroundColor = .systemBackground

        setupUI()
        setupDataTable()
        updateRowCountLabel()
        dataTable.reload()
    }

    private func setupUI() {
        controlsStack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            timingLabel,
            createRowCountStack(),
            reloadButton
        ])
        controlsStack.axis = .vertical
        controlsStack.spacing = 12
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        rowCountStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
    }

    private func createRowCountStack() -> UIStackView {
        let label = UILabel()
        label.text = "Rows:"
        label.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [label, rowCountLabel, rowCountStepper])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }

    private func setupDataTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        dataTable = SwiftDataTable(dataSource: self, options: config)
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dataTable)

        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 16),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateRowCountLabel() {
        currentRowCount = Int(rowCountStepper.value)
        rowCountLabel.text = "\(currentRowCount.formatted())"
    }

    @objc private func stepperChanged() {
        updateRowCountLabel()
    }

    @objc private func reloadTapped() {
        let startTime = Date()
        dataTable.reload()
        let elapsed = Date().timeIntervalSince(startTime)
        timingLabel.text = String(format: "%.3fs", elapsed)
    }
}

extension PerformanceDemoViewController: SwiftDataTableDataSource {
    func numberOfColumns(in: SwiftDataTable) -> Int {
        return 6
    }

    func numberOfRows(in: SwiftDataTable) -> Int {
        return currentRowCount
    }

    func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return [
            .string("Row \(index)"),
            .int(index * 100),
            .double(Double(index) * 1.5),
            .string("Data \(index % 100)"),
            .int(index % 1000),
            .string("End \(index)")
        ]
    }

    func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return ["Name", "Value", "Amount", "Category", "Code", "Status"][columnIndex]
    }
}
