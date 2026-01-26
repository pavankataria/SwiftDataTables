//
//  ShowHideElementsDemoViewController.swift
//  SwiftDataTables
//
//  Interactive demo for showing/hiding table elements.
//

import UIKit
import SwiftDataTables

final class ShowHideElementsDemoViewController: UIViewController {

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

    private var showFooter = true
    private var showSearch = true
    private var showVerticalScrollBar = true
    private var showHorizontalScrollBar = false

    // MARK: - UI

    private var controls: ExplanationControls!
    private var dataTable: SwiftDataTable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Show/Hide Elements"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        updateSummary()
        rebuildTable()
    }

    // MARK: - Actions

    @objc func toggleChanged(_ sender: UISwitch) {
        switch sender {
        case controls.footerToggle:
            showFooter = sender.isOn
        case controls.searchToggle:
            showSearch = sender.isOn
        case controls.verticalScrollToggle:
            showVerticalScrollBar = sender.isOn
        case controls.horizontalScrollToggle:
            showHorizontalScrollBar = sender.isOn
        default:
            break
        }
        updateSummary()
        rebuildTable()
    }

    // MARK: - UI Updates

    private func updateSummary() {
        var items: [String] = []
        items.append("Footer: \(showFooter ? "visible" : "hidden")")
        items.append("Search: \(showSearch ? "visible" : "hidden")")
        items.append("V-Scroll: \(showVerticalScrollBar ? "visible" : "hidden")")
        items.append("H-Scroll: \(showHorizontalScrollBar ? "visible" : "hidden")")
        controls.view.updateSummary(items.joined(separator: " | "))
    }

    private func rebuildTable() {
        dataTable?.removeFromSuperview()

        var config = DataTableConfiguration()
        config.shouldShowFooter = showFooter
        config.shouldShowSearchSection = showSearch
        config.shouldShowVerticalScrollBars = showVerticalScrollBar
        config.shouldShowHorizontalScrollBars = showHorizontalScrollBar

        let table = SwiftDataTable(data: sampleData, columns: columns, options: config)
        table.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

        addDataTable(table, below: controls.view)
        dataTable = table
    }
}
