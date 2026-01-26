//
//  SortingIndicatorVisibilityDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for controlling sorting indicator visibility.
//

import UIKit
import SwiftDataTables

final class SortingIndicatorVisibilityDemoViewController: UIViewController {

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

    private var showHeaderIndicator: Bool = true
    private var showFooterIndicator: Bool = false
    private var footerTriggersSorting: Bool = false

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sorting Indicator Visibility"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func headerIndicatorToggled(_ sender: UISwitch) {
        showHeaderIndicator = sender.isOn
        updateSummary()
        rebuildTable()
    }

    @objc func footerIndicatorToggled(_ sender: UISwitch) {
        showFooterIndicator = sender.isOn
        updateSummary()
        rebuildTable()
    }

    @objc func footerSortingToggled(_ sender: UISwitch) {
        footerTriggersSorting = sender.isOn
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        var parts: [String] = []

        if showHeaderIndicator {
            parts.append("Header indicators: ON")
        } else {
            parts.append("Header indicators: OFF (sorting still works)")
        }

        if showFooterIndicator {
            parts.append("Footer indicators: ON")
        }

        if footerTriggersSorting {
            parts.append("Footer sorting: enabled")
        }

        controls.view.updateSummary(parts.joined(separator: " | "))
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldShowHeaderSortingIndicator = showHeaderIndicator
        config.shouldShowFooterSortingIndicator = showFooterIndicator
        config.shouldFooterTriggerSorting = footerTriggersSorting
        config.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        config.columnWidthMode = .fitContentText(strategy: .maxMeasured)

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
