//
//  DefaultSortingDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

final class DefaultSortingDemoViewController: UIViewController {

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

    private var selectedColumnIndex: Int = 1
    private var sortOrder: DataTableSortType = .ascending

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Default Sorting"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls(columnHeaders: headers)
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func columnChanged(_ sender: UISegmentedControl) {
        selectedColumnIndex = sender.selectedSegmentIndex
        updateSummary()
        rebuildTable()
    }

    @objc func orderChanged(_ sender: UISegmentedControl) {
        sortOrder = sender.selectedSegmentIndex == 0 ? .ascending : .descending
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        let columnName = headers[selectedColumnIndex]
        let orderName = sortOrder == .ascending ? "ascending" : "descending"
        controls.view.updateSummary("Default sort: \(columnName) (\(orderName))")
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.defaultOrdering = DataTableColumnOrder(index: selectedColumnIndex, order: sortOrder)

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
