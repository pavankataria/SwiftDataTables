//
//  IncrementalUpdatesDemoViewController.swift
//  DemoSwiftDataTables
//
//  Created for SwiftDataTables.
//

import UIKit
import SwiftDataTables

/// Demo showcasing snapshot-based incremental updates.
///
/// The snapshot approach is simple:
/// 1. Modify your local data array (insert, delete, update)
/// 2. Call `dataTable.setData(tableData, animatingDifferences: true)`
/// 3. The table automatically diffs and animates the changes
final class IncrementalUpdatesDemoViewController: UIViewController {

    // MARK: - Properties

    private var dataTable: SwiftDataTable!
    private var tableData: DataTableContent = []
    private let headers = ["ID", "Name", "Value", "Status"]

    // MARK: - UI Controls

    private lazy var controlsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Snapshot diffing: modify data, call setData(), table animates the diff"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var buttonsRow1: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "+ Row", action: #selector(addRow)),
            makeButton(title: "+ 5 Rows", action: #selector(add5Rows)),
            makeButton(title: "- Row", action: #selector(deleteRow)),
            makeButton(title: "- 5 Rows", action: #selector(delete5Rows)),
        ])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var buttonsRow2: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "Update", action: #selector(updateRow)),
            makeButton(title: "Batch Mix", action: #selector(batchMix)),
            makeButton(title: "Clear All", action: #selector(clearAll)),
        ])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var animationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        return toggle
    }()

    private lazy var rowCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.text = "Rows: 0"
        return label
    }()

    private lazy var operationLogLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Ready"
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Incremental Updates"
        view.backgroundColor = .systemBackground
        setupViews()
        setupInitialData()
    }

    // MARK: - Setup

    private func setupViews() {
        // Animation row
        let animationRow = labeledRow(label: "Animate:", control: animationSwitch)

        // Info row
        let infoStack = UIStackView(arrangedSubviews: [rowCountLabel, UIView(), operationLogLabel])
        infoStack.axis = .horizontal
        infoStack.spacing = 8

        controlsStack.addArrangedSubview(descriptionLabel)
        controlsStack.addArrangedSubview(buttonsRow1)
        controlsStack.addArrangedSubview(buttonsRow2)
        controlsStack.addArrangedSubview(animationRow)
        controlsStack.addArrangedSubview(infoStack)

        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupInitialData() {
        // Start with 10 rows
        tableData = (0..<10).map { _ in generateRandomRow() }
        rebuildTable()
        updateRowCount()
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        let table = SwiftDataTable(data: tableData, headerTitles: headers, options: config)
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

    // MARK: - Actions (Snapshot Approach)
    //
    // Pattern: 1) Modify local data  2) Call setData()  3) Table diffs automatically

    @objc private func addRow() {
        let row = generateRandomRow()
        let index = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)
        tableData.insert(row, at: index)

        // Snapshot approach: just pass the new data, table calculates the diff
        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Inserted at index \(index)")
        updateRowCount()
    }

    @objc private func add5Rows() {
        let newRows = (0..<5).map { _ in generateRandomRow() }
        let insertIndex = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)

        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: insertIndex + i)
        }

        // One call handles the entire batch
        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Inserted 5 rows at \(insertIndex)")
        updateRowCount()
    }

    @objc private func deleteRow() {
        guard !tableData.isEmpty else {
            log("No rows to delete")
            return
        }

        let index = Int.random(in: 0..<tableData.count)
        tableData.remove(at: index)

        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Deleted row at index \(index)")
        updateRowCount()
    }

    @objc private func delete5Rows() {
        guard tableData.count >= 5 else {
            log("Need at least 5 rows")
            return
        }

        // Pick 5 unique random indices
        var indices = Set<Int>()
        while indices.count < 5 {
            indices.insert(Int.random(in: 0..<tableData.count))
        }

        // Remove in reverse order to preserve indices
        for index in indices.sorted(by: >) {
            tableData.remove(at: index)
        }

        // Single call handles all 5 deletions
        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Deleted 5 rows")
        updateRowCount()
    }

    @objc private func updateRow() {
        guard !tableData.isEmpty else {
            log("No rows to update")
            return
        }

        let index = Int.random(in: 0..<tableData.count)
        let newRow = generateRandomRow()
        tableData[index] = newRow

        // Update is detected as: old row removed, new row inserted
        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Updated row at index \(index)")
    }

    @objc private func batchMix() {
        guard tableData.count >= 2 else {
            log("Need at least 2 rows for batch")
            return
        }

        // Pick 2 unique indices to delete
        var deleteSet = Set<Int>()
        while deleteSet.count < min(2, tableData.count) {
            deleteSet.insert(Int.random(in: 0..<tableData.count))
        }

        // Remove in reverse order
        for i in deleteSet.sorted(by: >) {
            tableData.remove(at: i)
        }

        // Generate 3 new rows
        let newRows = (0..<3).map { _ in generateRandomRow() }
        let insertStart = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)

        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: insertStart + i)
        }

        // Snapshot approach handles mixed operations automatically
        // No need for performBatchUpdates - just call setData once
        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Batch: -\(deleteSet.count), +\(newRows.count)")
        updateRowCount()
    }

    @objc private func clearAll() {
        guard !tableData.isEmpty else {
            log("Already empty")
            return
        }

        let count = tableData.count
        tableData.removeAll()

        dataTable.setData(tableData, animatingDifferences: animationSwitch.isOn)

        log("Cleared \(count) rows")
        updateRowCount()
    }

    // MARK: - Helpers

    private func generateRandomRow() -> DataTableRow {
        let id = String(UUID().uuidString.prefix(8))
        let names = ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry"]
        let statuses = ["Active", "Pending", "Complete", "Error", "Review"]
        return [
            .string(id),
            .string(names.randomElement()!),
            .int(Int.random(in: 1...9999)),
            .string(statuses.randomElement()!)
        ]
    }

    private func updateRowCount() {
        rowCountLabel.text = "Rows: \(tableData.count)"
    }

    private func log(_ message: String) {
        operationLogLabel.text = message
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func labeledRow(label: String, control: UIView) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.text = label

        let row = UIStackView(arrangedSubviews: [titleLabel, control, UIView()])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }
}
