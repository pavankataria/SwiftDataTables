//
//  ScrollAnchoringDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo showcasing scroll anchoring during data updates.
/// Scroll down partway, then add/delete rows above - your scroll position stays stable.
final class ScrollAnchoringDemoViewController: UIViewController {

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var tableData: DataTableContent = []
    private let headers = ["#", "Name", "Category", "Value"]
    private var nextId = 1

    // MARK: - UI

    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scroll Anchoring"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()
    }

    // MARK: - Setup

    private func setupInitialData() {
        // Start with 50 rows so user can scroll
        tableData = (0..<50).map { _ in generateRow() }
        updateRowCount()
    }

    private func setupTable() {
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

    @objc func insertAbove() {
        // Insert 5 rows at the very top (above current viewport)
        let newRows = (0..<5).map { _ in generateRow() }
        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: i)
        }
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Inserted 5 rows at TOP - scroll position preserved!")
        updateRowCount()
    }

    @objc func insertBelow() {
        // Insert 5 rows at the bottom
        let newRows = (0..<5).map { _ in generateRow() }
        tableData.append(contentsOf: newRows)
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Inserted 5 rows at BOTTOM")
        updateRowCount()
    }

    @objc func deleteAbove() {
        // Delete first 5 rows (from the top)
        guard tableData.count >= 5 else {
            log("Need at least 5 rows")
            return
        }
        tableData.removeFirst(5)
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Deleted 5 rows from TOP - scroll position preserved!")
        updateRowCount()
    }

    @objc func deleteBelow() {
        // Delete last 5 rows
        guard tableData.count >= 5 else {
            log("Need at least 5 rows")
            return
        }
        tableData.removeLast(5)
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Deleted 5 rows from BOTTOM")
        updateRowCount()
    }

    @objc func scrollToMiddle() {
        // Scroll to approximately middle of content
        let collectionView = dataTable.collectionView
        let midY = (collectionView.contentSize.height - collectionView.bounds.height) / 2
        collectionView.setContentOffset(CGPoint(x: 0, y: max(0, midY)), animated: true)
        log("Scrolled to middle - now try Insert/Delete Above!")
    }

    @objc func batchMixAbove() {
        // Mixed operation: delete 3 from top, insert 5 at top
        guard tableData.count >= 3 else {
            log("Need at least 3 rows")
            return
        }
        tableData.removeFirst(3)
        let newRows = (0..<5).map { _ in generateRow() }
        for (i, row) in newRows.enumerated() {
            tableData.insert(row, at: i)
        }
        dataTable.setData(tableData, animatingDifferences: controls.animationSwitch.isOn)
        log("Batch: -3, +5 at TOP - scroll preserved!")
        updateRowCount()
    }

    @objc func animationToggleChanged(_ sender: UISwitch) {
        log(sender.isOn ? "Animations enabled" : "Animations disabled")
    }

    // MARK: - Helpers

    private func generateRow() -> DataTableRow {
        let id = nextId
        nextId += 1
        let names = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta"]
        let categories = ["Type A", "Type B", "Type C", "Type D"]
        return [
            .int(id),
            .string(names.randomElement()!),
            .string(categories.randomElement()!),
            .int(Int.random(in: 100...9999))
        ]
    }

    private func updateRowCount() {
        controls.rowCountLabel.text = "Rows: \(tableData.count)"
    }

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}
