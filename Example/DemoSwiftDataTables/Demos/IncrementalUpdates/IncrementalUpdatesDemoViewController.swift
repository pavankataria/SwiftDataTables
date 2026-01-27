//
//  IncrementalUpdatesDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo showcasing snapshot-based incremental updates.
final class IncrementalUpdatesDemoViewController: UIViewController {

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var tableData: DataTableContent = []
    private let headers = ["ID", "Name", "Value", "Status"]

    // MARK: - UI

    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Data Updates"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
    }

    // MARK: - Setup

    private func setupInitialData() {
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
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
    }

    // MARK: - Actions

    @objc func animationToggleChanged(_ sender: UISwitch) {
        // No-op, we just read the switch state when needed
    }

    @objc func addRow() {
        let row = generateRandomRow()
        let index: Int
        if controls.randomInsertSwitch.isOn {
            index = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)
        } else {
            index = tableData.count
        }
        tableData.insert(row, at: index)
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Inserted at index \(index)")
        updateRowCount()
    }

    @objc func add5Rows() {
        let newRows = (0..<5).map { _ in generateRandomRow() }
        let insertIndex: Int
        if controls.randomInsertSwitch.isOn {
            insertIndex = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)
        } else {
            insertIndex = tableData.count
        }
        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: insertIndex + i)
        }
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Inserted 5 rows at \(insertIndex)")
        updateRowCount()
    }

    @objc func deleteRow() {
        guard !tableData.isEmpty else {
            log("No rows to delete")
            return
        }
        let index = Int.random(in: 0..<tableData.count)
        tableData.remove(at: index)
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Deleted row at index \(index)")
        updateRowCount()
    }

    @objc func delete5Rows() {
        guard tableData.count >= 5 else {
            log("Need at least 5 rows")
            return
        }
        var indices = Set<Int>()
        while indices.count < 5 {
            indices.insert(Int.random(in: 0..<tableData.count))
        }
        for index in indices.sorted(by: >) {
            tableData.remove(at: index)
        }
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Deleted 5 rows")
        updateRowCount()
    }

    @objc func updateRow() {
        guard !tableData.isEmpty else {
            log("No rows to update")
            return
        }
        let index = Int.random(in: 0..<tableData.count)
        tableData[index] = generateRandomRow()
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Updated row at index \(index)")
    }

    @objc func batchMix() {
        guard tableData.count >= 2 else {
            log("Need at least 2 rows for batch")
            return
        }
        var deleteSet = Set<Int>()
        while deleteSet.count < min(2, tableData.count) {
            deleteSet.insert(Int.random(in: 0..<tableData.count))
        }
        for i in deleteSet.sorted(by: >) {
            tableData.remove(at: i)
        }
        let newRows = (0..<3).map { _ in generateRandomRow() }
        let insertStart = tableData.isEmpty ? 0 : Int.random(in: 0...tableData.count)
        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: insertStart + i)
        }
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Batch: -\(deleteSet.count), +\(newRows.count)")
        updateRowCount()
    }

    @objc func clearAll() {
        guard !tableData.isEmpty else {
            log("Already empty")
            return
        }
        let count = tableData.count
        tableData.removeAll()
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Cleared \(count) rows")
        updateRowCount()
    }

    @objc func randomiseAll() {
        guard tableData.count >= 2 else {
            log("Need at least 2 rows")
            return
        }
        tableData.shuffle()
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Randomised \(tableData.count) rows")
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
        controls.rowCountLabel.text = "Rows: \(tableData.count)"
    }

    private func log(_ message: String) {
        controls.operationLogLabel.text = message
    }
}
