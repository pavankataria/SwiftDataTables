//
//  RowSelectionDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo showing row selection callbacks.
//

import UIKit
import SwiftDataTables

final class RowSelectionDemoViewController: UIViewController {

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

    // MARK: - State

    private var selectionLog: [String] = []

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Row Selection"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        rebuildTable()
    }

    // MARK: - Actions

    @objc func clearLog() {
        selectionLog.removeAll()
        updateLogDisplay()
    }

    private func addLogEntry(_ entry: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        selectionLog.insert("[\(timestamp)] \(entry)", at: 0)
        if selectionLog.count > 5 {
            selectionLog.removeLast()
        }
        updateLogDisplay()
    }

    private func updateLogDisplay() {
        if selectionLog.isEmpty {
            controls.selectionLogLabel.text = "Tap a row to see selection events..."
        } else {
            controls.selectionLogLabel.text = selectionLog.joined(separator: "\n")
        }
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        let table = SwiftDataTable(data: sampleData, columns: columns)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        table.delegate = self

        installDataTable(table, below: controls.view)
        dataTable = table
    }
}

// MARK: - SwiftDataTableDelegate

extension RowSelectionDemoViewController: SwiftDataTableDelegate {
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let value = dataTable.data(for: indexPath)
        addLogEntry("Selected row \(indexPath.item): \(value.stringRepresentation)")
    }

    func didDeselectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        let value = dataTable.data(for: indexPath)
        addLogEntry("Deselected row \(indexPath.item): \(value.stringRepresentation)")
    }
}
