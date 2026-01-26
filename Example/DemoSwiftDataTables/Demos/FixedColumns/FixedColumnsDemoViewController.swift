//
//  FixedColumnsDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for fixed (frozen) columns.
//

import UIKit
import SwiftDataTables

final class FixedColumnsDemoViewController: UIViewController {

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

    private var leftColumnsCount: Int = 1
    private var rightColumnsCount: Int = 1
    private let maxColumns = 6

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fixed Columns"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls(maxColumns: maxColumns)
        installExplanation(controls.view)

        updateUI()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func leftStepperChanged(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        if newValue + rightColumnsCount >= maxColumns {
            rightColumnsCount = max(0, maxColumns - newValue - 1)
            controls.rightColumnsStepper.value = Double(rightColumnsCount)
        }
        leftColumnsCount = newValue
        updateUI()
        rebuildTable()
    }

    @objc func rightStepperChanged(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        if leftColumnsCount + newValue >= maxColumns {
            leftColumnsCount = max(0, maxColumns - newValue - 1)
            controls.leftColumnsStepper.value = Double(leftColumnsCount)
        }
        rightColumnsCount = newValue
        updateUI()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateUI() {
        controls.leftColumnsLabel.text = "\(leftColumnsCount)"
        controls.rightColumnsLabel.text = "\(rightColumnsCount)"

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
            controls.view.updateSummary("No frozen columns. All columns scroll freely.")
        } else {
            let scrollableCount = maxColumns - leftColumnsCount - rightColumnsCount
            summaryParts.append("Scrollable columns: \(scrollableCount)")
            controls.view.updateSummary(summaryParts.joined(separator: "\n"))
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

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
