//
//  ColumnSortabilityDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

final class ColumnSortabilityDemoViewController: UIViewController {

    // MARK: - Data

    let sampleData = samplePeople()

    let columns: [DataTableColumn<SamplePerson>] = [
        .init("ID", \.id),
        .init("Name", \.name),
        .init("Email", \.email),
        .init("Number", \.phone),
        .init("City", \.city),
        .init("Balance", \.balance)
    ]

    private var headers: [String] {
        columns.map { $0.header }
    }

    // MARK: - State

    /// Tracks which columns are sortable (all true by default)
    private var sortableColumns: [Bool] = []

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Column Sortability"
        view.backgroundColor = .systemBackground

        // Initialize all columns as sortable
        sortableColumns = Array(repeating: true, count: columns.count)

        controls = makeExplanationControls(columnHeaders: headers)
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func toggleChanged(_ sender: UISwitch) {
        let columnIndex = sender.tag
        sortableColumns[columnIndex] = sender.isOn
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        let sortableNames = headers.enumerated()
            .filter { sortableColumns[$0.offset] }
            .map { $0.element }

        if sortableNames.isEmpty {
            controls.view.updateSummary("No columns are sortable")
        } else if sortableNames.count == headers.count {
            controls.view.updateSummary("All columns are sortable")
        } else {
            controls.view.updateSummary("Sortable: \(sortableNames.joined(separator: ", "))")
        }
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.isColumnSortable = { [weak self] columnIndex in
            guard let self = self else { return true }
            return self.sortableColumns[columnIndex]
        }
        config.columnWidthMode = .fitContentText(strategy: .maxMeasured)

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
