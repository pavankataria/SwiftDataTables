//
//  PerformanceDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

class PerformanceDemoViewController: UIViewController {

    // MARK: - State

    private var currentRowCount: Int = 50000

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Performance Stress Test"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateRowCountLabel()
        setupDataTable()
        dataTable.reload()
    }

    // MARK: - Setup

    private func setupDataTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false

        dataTable = SwiftDataTable(dataSource: self, options: config)
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dataTable)

        NSLayoutConstraint.activate([
            dataTable.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            dataTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc func stepperChanged(_ sender: UIStepper) {
        updateRowCountLabel()
    }

    @objc func reloadTapped() {
        let startTime = Date()
        dataTable.reload()
        let elapsed = Date().timeIntervalSince(startTime)
        controls.timingLabel.text = String(format: "%.3fs", elapsed)
    }

    // MARK: - UI Updates

    private func updateRowCountLabel() {
        currentRowCount = Int(controls.rowCountStepper.value)
        controls.rowCountLabel.text = currentRowCount.formatted()
    }
}

// MARK: - SwiftDataTableDataSource

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
